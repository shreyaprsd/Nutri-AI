//
//  HomeView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries: [NutritionModel]
    @Binding var selectedImage: UIImage?
    @State private var geminiVM = GeminiViewModel()
    @State private var imageID = UUID()
    @Environment(\.modelContext) private var modelContext: ModelContext
    var body: some View {
        Group {
            FoodEntryList(selectedImage: $selectedImage)
                .task(id: imageID) {
                    print("New image captured ith id :(\(imageID)), starting analysis")
                    if let selectedImage {
                        await geminiVM.analyzeFood(image: selectedImage, modelContext: modelContext)
                    }
                }
                .onChange(of: selectedImage) { _, newValue in
                    if newValue != nil {
                        imageID = UUID()
                        print("Image changed, new ID generated")
                    }
                }
        }
    }
}
