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
