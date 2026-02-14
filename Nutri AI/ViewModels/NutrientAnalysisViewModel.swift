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
    func analyzeFood(image: UIImage, modelContext: ModelContext, onComplete: @escaping () -> Void) async {
        isLoading = true
        errorMessage = nil
        var didComplete = false
        defer {
            isLoading = false
            if !didComplete {
                onComplete()
            }
        }
        do {
            let response = try await analysisService.analyze(image: image)
            nutritionInfo = response

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                return
            }
            let entry = NutritionModel(createdAt: Date(), imageData: imageData, response: response)
            let foodEntryViewModel = FoodEntryViewModel(modelContext: modelContext)

            try await foodEntryViewModel.addFoodEntry(entry, image: image, onLocalSaveComplete: onComplete)
            didComplete = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
