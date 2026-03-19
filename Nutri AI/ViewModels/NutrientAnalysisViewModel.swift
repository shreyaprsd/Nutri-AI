//
//  NutrientAnalysisViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import Observation
import SwiftData
import UIKit

struct LoadingItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

@Observable
final class NutrientAnalysisViewModel {
    var isLoading = false
    var loadingItems: [LoadingItem] = []
    var nutritionInfo: NutritionResponse?
    var errorMessage: String?
    private var activeAnalysisCount = 0
    private let analysisService: NutritionalAnalysisServiceProtocol

    init(analysisService: NutritionalAnalysisServiceProtocol = NutritionalAnalysisService()) {
        self.analysisService = analysisService
    }

    @MainActor
    func analyzeFood(image: UIImage, modelContext: ModelContext) async {
        activeAnalysisCount += 1
        isLoading = true
        let loadingItem = LoadingItem(image: image)
        loadingItems.insert(loadingItem, at: 0)
        errorMessage = nil

        do {
            let response = try await analysisService.analyze(image: image)
            nutritionInfo = response

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                hideLoadingIfDone(for: loadingItem)
                return
            }
            let entry = NutritionModel(createdAt: Date(), imageData: imageData, response: response)
            let foodEntryViewModel = FoodEntryViewModel(modelContext: modelContext)

            try await foodEntryViewModel.addFoodEntry(entry, image: image, onLocalSaveComplete: { self.hideLoadingIfDone(for: loadingItem) })
        } catch {
            hideLoadingIfDone(for: loadingItem)
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func hideLoadingIfDone(for item: LoadingItem) {
        loadingItems.removeAll { $0.id == item.id }
        activeAnalysisCount -= 1
        if activeAnalysisCount == 0 {
            isLoading = false
        }
    }
}
