//
//  NutrientAnalysisViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import Observation
import SwiftData
import UIKit

@Observable
final class NutrientAnalysisViewModel {
    var isLoading = false
    var nutritionInfo: NutritionResponse?
    var errorMessage: String?
    private let analysisService: NutritionalAnalysisServiceProtocol
    
    init(analysisService: NutritionalAnalysisServiceProtocol = NutritionalAnalysisService()) {
        self.analysisService = analysisService
    }

    @MainActor
    func analzeFood(image: UIImage, modelContext: ModelContext, onComplete: @escaping () -> Void) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        do {
            let response = try await analysisService.analyze(image: image)
            nutritionInfo = response

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return
            }
            let entry = NutritionModel(createdAt: Date(), imageData: imageData, response: response)
            let nutritionVM = NutritionVM(modelContext: modelContext)
            try await nutritionVM.addFoodEntry(entry)
            onComplete()
            print("saved to local db")
            let repo = FoodRepository(modelContext: modelContext)
            try await repo.saveFoodEntryToFirestore(food: entry, image: image)
            print("Saved to firestore")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
