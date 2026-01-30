//
//  UserInfoRepository.swift
//  Nutri AI
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import SwiftData

class UserInfoRepository {
    private let db = Firestore.firestore()
    private var modelContext: ModelContext
    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "UserInfoRepository")

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveUserInfoToFirestore(_ userInfo: UserInfoModel) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw UserInfoError.userNotAuthenticated
        }

        let remoteModel = UserInfoRemoteModel(from: userInfo)
        let docRef = db.collection("users").document(userId).collection("userInfo").document("profile")
        try docRef.setData(from: remoteModel, merge: true)
        logger.info("UserInfo saved to Firestore")
    }

    func deleteUserInfoFromFirestore() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw UserInfoError.userNotAuthenticated
        }

        let docRef = db.collection("users").document(userId).collection("userInfo").document("profile")

        do {
            let document = try await docRef.getDocument()

            if document.exists {
                try await docRef.delete()
                
                let verifyDoc = try await docRef.getDocument()
                if verifyDoc.exists {
                    throw UserInfoError.onlineDeletionFailed
                }
            }
        } catch {
            throw error
        }
    }

    func deleteUserInfoFromBothDB(_ userInfo: UserInfoModel) async throws {
        do {
            modelContext.delete(userInfo)
            try modelContext.save()
            logger.info("UserInfo deleted locally")
        } catch {
            throw UserInfoError.localDeletionFailed
        }

        do {
            try await deleteUserInfoFromFirestore()
        } catch {
            throw UserInfoError.onlineDeletionFailed
        }
    }

    enum UserInfoError: Error {
        case userNotAuthenticated
        case localDeletionFailed
        case onlineDeletionFailed

        var errorDescription: String? {
            switch self {
            case .userNotAuthenticated:
                "User is not authenticated"
            case .localDeletionFailed:
                "Failed to delete UserInfo locally"
            case .onlineDeletionFailed:
                "Failed to delete UserInfo from Firestore"
            }
        }
    }
}
