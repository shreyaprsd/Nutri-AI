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

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
    }
}
