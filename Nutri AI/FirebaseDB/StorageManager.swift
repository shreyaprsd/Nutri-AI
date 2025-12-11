//
//  StorageManager.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseStorage
import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()

    private init() {}

    // upload the image and return url
    func uploadFoodImage(imageData: Data) async throws -> String {
        // reference to the file location
        let storageRef = storage.reference()
        let foodImageRef = storageRef.child(
            "foodImages/\(UUID().uuidString).jpg")

        // setting up of metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // upload the image
        _ = try await foodImageRef.putDataAsync(
            imageData, metadata: metadata
        )

        // download the url
        let downloadURL = try await foodImageRef.downloadURL()
        return downloadURL.absoluteString
    }

    // delete the image if needed
    func deleteImage(imageURL: String) async throws {
        let storageRef = storage.reference(forURL: imageURL)
        _ = try await storageRef.delete()
        print("Successfully deleted from storage")
    }
}
