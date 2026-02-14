//
//  FoodEntryViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/11/25.
//

import Foundation
import SwiftData
import UIKit

@Observable
class FoodEntryViewModel {
    private var modelContext: ModelContext
    private var foodRepository: FoodRepository

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        foodRepository = FoodRepository(modelContext: modelContext)
    }

    // save the data
    func addFoodEntry(_ food: NutritionModel, image: UIImage?, onLocalSaveComplete: () -> Void) async throws {
        try await foodRepository.saveFoodToBothDB(food: food, image: image, onLocalSaveComplete: onLocalSaveComplete)
    }

    // delete the data
    func deleteFoodEntry(_ food: NutritionModel) async throws {
        try await foodRepository.deleteFoodFromBothDB(for: food)
    }

    // update serving multiplier
    func updateServingMultiplier(for food: NutritionModel, multiplier: Double) async throws {
        food.servingMultiplier = multiplier
        try modelContext.save()

        try await foodRepository.updateFoodEntryToFirestore(food: food, multiplier: multiplier)
    }

    // delete all food entries (for account deletion)
    func deleteAllLocalFoodEntries() async throws {
        try await foodRepository.deleteAllLocalFoods()
    }

    // background sync for specific date food entry
    func refreshEntries(for selectedDate: Date) async {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return
        }
        await BackgroundSyncManager.shared.refreshFoodsForDate(
            dayStart: dayStart,
            dayEnd: dayEnd,
            modelContext: modelContext
        )
    }
}
