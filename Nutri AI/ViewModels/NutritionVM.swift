//
//  NutritionVM.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/11/25.
//

import Foundation
import SwiftData

@Observable
class NutritionVM {
    private var modelContext: ModelContext
    private var foodRepository: FoodRepository
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        foodRepository = FoodRepository(modelContext: modelContext)
    }

    // save the data
    func addFoodEntry(_ food: NutritionModel) async throws {
        modelContext.insert(food)
        try modelContext.save()
    }

    // delete the data
    func deleteFoodEntry(_ food: NutritionModel) async throws {
        modelContext.delete(food)
        try modelContext.save()

        try await foodRepository.deleteFoodEntryFromFirestore(for: food)
        print("Deleted from firestore")
    }

    // update serving multiplier
    func updateServingMultiplier(for food: NutritionModel, multiplier: Double) async throws {
        food.servingMultiplier = multiplier
        try modelContext.save()

        try await foodRepository.updateFoodEntryToFirestore(food: food, multiplier: multiplier)
    }
}
