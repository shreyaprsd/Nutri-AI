//
//  FirestoreDataSyncManager.swift
//  Nutri AI
//
//
//

import BackgroundTasks
import FirebaseAuth
import FirebaseFirestore
import OSLog
import SwiftData

class FirestoreDataSyncManager {
    static let shared = FirestoreDataSyncManager()
    static let taskIdentifier = "com.shreyaprasad.NutriAI.firestoresync"
    private let queue = DispatchQueue(label: "com.shreyaprasad.NutriAI.syncQueue")
    private var pendingSyncItems: [(food: NutritionModel, imageData: Data?)] = []
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "BackgroundSyncManager")
    private init() {}

    // register the background task
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handleBackgroundSync(task: processingTask)
            self.logger.info("Background task registered")
        }
    }

    // Called when Firestore save fails
    func addPendingSync(food: NutritionModel, imageData: Data?) {
        queue.sync {
            pendingSyncItems.append((food, imageData))
        }
        let request = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        request.requiresExternalPower = true
        request.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Background task scheduled")

        } catch {
            logger.error("Background task scheduling failed \(error.localizedDescription)")
        }
    }

    // Called by iOS when background task runs
    private func handleBackgroundSync(task: BGProcessingTask) {
        logger.debug("Items to sync: \(self.pendingSyncItems.count)")
        task.expirationHandler = { task.setTaskCompleted(success: false) }

        Task {
            let success = await performSync()
            task.setTaskCompleted(success: success)
            logger.info("Background task finished")
        }
    }

    // Sync all pending items
    private func performSync() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            return false
        }
        logger.debug("Syncing \(self.pendingSyncItems.count) items")

        var successIndices: [Int] = []

        for (index, item) in pendingSyncItems.enumerated() {
            logger.debug("Syncing: \(item.food.foodName)")

            do {
                // Upload image if exists
                var imageURL: String?
                if let imageData = item.imageData {
                    imageURL = try await StorageManager.shared.uploadFoodImage(imageData: imageData)
                }

                // Save to Firestore
                logger.info("Saving to Firestore")
                let foodData = RemoteModel(model: item.food, imageURL: imageURL)
                let foodRef = db.collection("users")
                    .document(userId)
                    .collection("foods")
                    .document(item.food.id.uuidString)

                try foodRef.setData(from: foodData)

                logger.info("Successfully synced: \(item.food.foodName)")
                successIndices.append(index)

            } catch {
                logger.error("Failed to sync: \(error.localizedDescription)")
            }
        }

        // Remove successfully synced items
        for index in successIndices.reversed() {
            let removed = pendingSyncItems.remove(at: index)
            logger.info("Removed: \(removed.food.foodName)")
        }

        return successIndices.count > 0 || pendingSyncItems.isEmpty
    }
}
