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
}
