//
//  UserManager.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()

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
                print("User document created \(user.uid)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func deleteUserDocument(for user: User) async {
        let userRef = db.collection("users").document(user.uid)
        print("Attempting to delete user document: \(user.uid)")
        do {
            // Delete all food entries first
            let foodsCollection = userRef.collection("foods")
            let foodDocs = try await foodsCollection.getDocuments()

            for doc in foodDocs.documents {
                if let imageURL = doc.data()["foodImageURL"] as? String {
                    print("Deleting image: \(imageURL)")
                    try? await StorageManager.shared.deleteImage(imageURL: imageURL)
                }
                try await doc.reference.delete()
                print("Deleted food entry: \(doc.documentID)")
            }
            // Then delete the user document
            try await userRef.delete()
            print("User document deleted successfully: \(user.uid)")

        } catch {
            print("Error deleting user document: \(error.localizedDescription)")
        }
    }
}
