//
//  NutrientAnalysisViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import Observation
import SwiftData
import UIKit

@MainActor
struct LoadingItem: Identifiable {
    let id: UUID
    let image: UIImage

    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
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

        defer { hideLoadingIfDone(for: loadingItem) }

        do {
            let response = try await analysisService.analyze(image: image)
            nutritionInfo = response

            guard let imageData = image.resizedForUpload().jpegData(compressionQuality: 0.8) else {
                hideLoadingIfDone(for: loadingItem)
                return
            }
            let entry = NutritionModel(createdAt: Date(), imageData: imageData, response: response)
            let foodEntryViewModel = FoodEntryViewModel(modelContext: modelContext)

            try await foodEntryViewModel.addFoodEntry(entry, image: image, onLocalSaveComplete: { self.hideLoadingIfDone(for: loadingItem) })
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func hideLoadingIfDone(for item: LoadingItem) {
        guard loadingItems.contains(where: { $0.id == item.id }) else { return }
        loadingItems.removeAll { $0.id == item.id }
        activeAnalysisCount -= 1
        if activeAnalysisCount == 0 {
            isLoading = false
        }
    }
}
