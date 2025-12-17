//
//  FirestoreDataSyncManager.swift
//  Nutri AI
//
//
//

import BackgroundTasks
import FirebaseAuth
import FirebaseFirestore
import UIKit

class BackgroundSyncManager {
    static let shared = BackgroundSyncManager()
    static let taskIdentifier = "com.shreyaprasad.NutriAI.firestoresync"

    private var pendingSyncItems: [(food: NutritionModel, image: UIImage?)] = []
    private let db = Firestore.firestore()

    private init() {}

    // register the background task
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundSync(task: task as! BGProcessingTask)
            print("Background task registered")
        }
    }

    // Called when Firestore save fails
    func addPendingSync(food: NutritionModel, image: UIImage?) {
        pendingSyncItems.append((food, image))

        let request = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        request.requiresExternalPower = true
        request.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled")
        } catch {
            print("Background task scheduling failed \(error.localizedDescription)")
        }
    }

    // Called by iOS when background task runs
    private func handleBackgroundSync(task: BGProcessingTask) {
        print("Items to sync: \(pendingSyncItems.count)")
        task.expirationHandler = { task.setTaskCompleted(success: false) }

        Task {
            let success = await performSync()
            task.setTaskCompleted(success: success)
            print("Background task finished")
        }
    }

    // Sync all pending items
    private func performSync() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            return false
        }
        print("Syncing \(pendingSyncItems.count) items")

        var successIndices: [Int] = []

        for (index, item) in pendingSyncItems.enumerated() {
            print("Syncing: \(item.food.foodName)")

            do {
                // Upload image if exists
                var imageURL: String?
                if let image = item.image,
                   let imageData = image.jpegData(compressionQuality: 0.8)
                {
                    imageURL = try await StorageManager.shared.uploadFoodImage(imageData: imageData)
                }

                // Save to Firestore
                print("Saving to Firestore")
                let foodData = RemoteModel(model: item.food, imageURL: imageURL)
                let foodRef = db.collection("users")
                    .document(userId)
                    .collection("foods")
                    .document(item.food.id.uuidString)

                try foodRef.setData(from: foodData)

                print("Successfully synced: \(item.food.foodName)")
                successIndices.append(index)

            } catch {
                print("Failed to sync: \(error.localizedDescription)")
            }
        }

        // Remove successfully synced items
        for index in successIndices.reversed() {
            let removed = pendingSyncItems.remove(at: index)
            print("   ✓ Removed: \(removed.food.foodName)")
        }

        return successIndices.count > 0 || pendingSyncItems.isEmpty
    }
}
