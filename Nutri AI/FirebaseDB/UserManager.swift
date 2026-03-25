//
//  UserManager.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "UserManager")
    private init() {}

    func createUserDocument(for user: User) async {
        let userRef = db.collection("users").document(user.uid)
        do {
            let document = try await userRef.getDocument()
            if !document.exists {
                try await userRef.setData(
                    [
                        "id": user.uid,
                        "displayName": user.displayName ?? "",
                        "email": user.email ?? "",
                    ], merge: true
                )
                logger.info("User document created \(user.uid)")
            }
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    func deleteUserDocument(for user: User) async {
        let userRef = db.collection("users").document(user.uid)
        logger.info("Attempting to delete user document: \(user.uid)")
        do {
            // Delete all food entries first
            let foodsCollection = userRef.collection("foods")
            let foodDocs = try await foodsCollection.getDocuments()

            for doc in foodDocs.documents {
                if let imageURL = doc.data()["food_image_url"] as? String {
                    logger.info("Deleting image: \(imageURL)")
                    try? await StorageManager.shared.deleteImage(imageURL: imageURL)
                }
                try await doc.reference.delete()
                logger.info("Deleted food entry: \(doc.documentID)")
            }
            // Then delete the user document
            try await userRef.delete()
            logger.info("User document deleted successfully: \(user.uid)")

        } catch {
            logger.error("Error deleting user document: \(error.localizedDescription)")
        }
    }
}
