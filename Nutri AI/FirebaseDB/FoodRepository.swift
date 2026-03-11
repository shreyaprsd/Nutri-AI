//
//  FoodRepository.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import SwiftData

class FoodRepository {
    private let db = Firestore.firestore()
    private var modelContext: ModelContext
    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "FoodRepository")

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveFoodEntryToFirestore(food: NutritionModel, image: UIImage?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FoodDataError.userNotAuthenticated
        }
        var imageURL: String?
        if let image,
           let imageData = image.jpegData(compressionQuality: 0.8)
        {
            imageURL = try await StorageManager.shared.uploadFoodImage(imageData: imageData)
        }
        let foodData = RemoteModel(model: food, imageURL: imageURL)

        let foodRef = db.collection("users").document(userId).collection("foods").document(food.id.uuidString)
        try foodRef.setData(from: foodData)
    }

    func updateFoodEntryToFirestore(food: NutritionModel, multiplier _: Double) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FoodDataError.userNotAuthenticated
        }

        let docRef = db.collection("users").document(userId).collection("foods").document(food.id.uuidString)
        let document = try await docRef.getDocument()
        var foodRemote = try document.data(as: RemoteModel.self)

        foodRemote.servingMultiplier = food.servingMultiplier
        try docRef.setData(from: foodRemote, merge: true)
        logger.info("Food nutrients updated in firestore db")
    }

    func deleteFoodEntryFromFirestore(for food: NutritionModel) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw FoodDataError.userNotAuthenticated
        }

        let foodRef = db.collection("users").document(userID).collection("foods").document(food.id.uuidString)
        do {
            let document = try await foodRef.getDocument()
            if document.exists {
                let remoteFood = try document.data(as: RemoteModel.self)

                if let imageURL = remoteFood.foodImageURL {
                    try await StorageManager.shared.deleteImage(imageURL: imageURL)
                }
                try await foodRef.delete()
            }
        } catch {
            logger.error("Error deleting food\(food.foodName)")
            throw error
        }
    }

    func saveFoodToBothDB(food: NutritionModel, image: UIImage?, onLocalSaveComplete: () -> Void) async throws {
        // save the data locally
        do {
            modelContext.insert(food)
            try modelContext.save()
            onLocalSaveComplete()
            logger.info("Data saved locally")
        } catch {
            throw FoodDataError.localSavingFailed
        }

        // save the data to firestoreDB
        do {
            try await saveFoodEntryToFirestore(food: food, image: image)
            logger.info("Data saved to Firestore")
        } catch {
            logger.error("Firestore save failed, scheduling background sync")
            BackgroundSyncManager.shared.addPendingSync(food: food, image: image)
        }
    }

    func deleteFoodFromBothDB(for food: NutritionModel) async throws {
        // delete locally
        do {
            modelContext.delete(food)
            try modelContext.save()
            logger.info("Data deleted locally")
        } catch {
            throw FoodDataError.localDeletionFailed
        }

        // delete from Firebase DB
        do {
            try await deleteFoodEntryFromFirestore(for: food)
            logger.info("Food deleted from Firestore")
        } catch {
            throw FoodDataError.onlineDeletionFailed
        }
    }

    func updateFoodInBothDB(food: NutritionModel, multiplier: Double) async throws {
        // update locally
        do {
            try modelContext.save()
            logger.info("Data updated locally")
        } catch {
            throw FoodDataError.localUpdateFailed
        }

        // update in firestore db
        do {
            try await updateFoodEntryToFirestore(food: food, multiplier: multiplier)
            logger.info("Food updated in Firestore")
        } catch {
            throw FoodDataError.onlineUpdateFailed
        }
    }

    func deleteAllLocalFoods() async throws {
        let descriptor = FetchDescriptor<NutritionModel>()
        let allFoods: [NutritionModel] = try modelContext.fetch(descriptor)
        for food in allFoods {
            modelContext.delete(food)
        }
        try modelContext.save()
        logger.info("All local foods deleted")
    }

    func pullFoodsFromFirestore(dayStart: Date, dayEnd: Date) async throws {
        let remoteFoods = try await fetchFoodsFromFirestore(dayStart: dayStart, dayEnd: dayEnd)
        try await MainActor.run {
            try upsertFoods(remoteFoods)
        }
    }

    private func fetchFoodsFromFirestore(dayStart: Date, dayEnd: Date) async throws -> [RemoteModel] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FoodDataError.userNotAuthenticated
        }
        let startTimestamp = Timestamp(date: dayStart)
        let endTimestamp = Timestamp(date: dayEnd)
        let query = db.collection("users")
            .document(userId)
            .collection("foods")
            .whereField("created_At", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("created_At", isLessThan: endTimestamp)
            .order(by: "created_At", descending: true)
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.map { try $0.data(as: RemoteModel.self) }
    }

    @MainActor
    private func upsertFoods(_ remoteFoods: [RemoteModel]) throws {
        // collect all valid UUIDs from remote foods
        let remoteMapping: [(UUID, RemoteModel)] = remoteFoods.compactMap { remote in
            guard let id = remote.id, let uuid = UUID(uuidString: id) else { return nil }
            return (uuid, remote)
        }

        // Fetch all local entries unfiltered, then filter in-memory.
        let allIDs = Set(remoteMapping.map(\.0))
        let descriptor = FetchDescriptor<NutritionModel>()
        let allLocal = try modelContext.fetch(descriptor)
        let existingFoods = allLocal.filter { allIDs.contains($0.id) }

        // build a dictionary for instant lookup by ID
        let existingByID = Dictionary(uniqueKeysWithValues: existingFoods.map { ($0.id, $0) })

        for (uuid, remote) in remoteMapping {
            if let existing = existingByID[uuid] {
                remote.applyTo(existing)
            } else {
                let model = remote.toNutritionModel()
                modelContext.insert(model)
            }
        }
        try modelContext.save()
    }

    enum FoodDataError: Error {
        case userNotAuthenticated
        case localSavingFailed
        case onlineSavingFailed
        case localDeletionFailed
        case onlineDeletionFailed
        case localUpdateFailed
        case onlineUpdateFailed

        var errorDescription: String? {
            switch self {
            case .localSavingFailed:
                "Failed to save the food to the local database"
            case .onlineSavingFailed:
                "Failed to save the food to the online database"
            case .localDeletionFailed:
                "Failed to delete the food from the local database"
            case .onlineDeletionFailed:
                "Failed to delete the food from the online database"
            case .localUpdateFailed:
                "Failed to update the food in the local database"
            case .onlineUpdateFailed:
                "Failed to update the food in the online database"
            case .userNotAuthenticated:
                "User is not authenticated"
            }
        }
    }
}
