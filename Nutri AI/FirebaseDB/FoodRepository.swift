//
//  FoodRepository.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftData

class FoodRepository {
    private let db = Firestore.firestore()
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveFoodEntryToFirestore(food: NutritionModel, image: UIImage?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
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
            return
        }

        let docRef = db.collection("users").document(userId).collection("foods").document(food.id.uuidString)
        let document = try await docRef.getDocument()
        var foodRemote = try document.data(as: RemoteModel.self)

        foodRemote.servingMultiplier = food.servingMultiplier
        try docRef.setData(from: foodRemote, merge: true)
        print("Food nutrients updated in firestore db")
    }

    func deleteFoodEntryFromFirestore(for food: NutritionModel) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("User not signed in ")
        }

        let foodRef = db.collection("users").document(userID).collection("foods").document(food.foodName)
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
            print("Error deleting food\(food.foodName)")
            throw error
        }
    }
}
