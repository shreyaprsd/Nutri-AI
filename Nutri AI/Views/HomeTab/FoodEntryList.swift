//
//  FoodEntryList.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import OSLog
import SwiftData
import SwiftUI

struct FoodEntryList: View {
    let entries: [NutritionModel]
    @Binding var selectedImage: UIImage?
    @Binding var selectedDate: Date
    var analysisVM: NutrientAnalysisViewModel
    @State private var selectedFoodEntry: NutritionModel?
    @Binding var hideFloatingButton: Bool
    private let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "FoodEntryList")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recently logged")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }

            LazyVStack(spacing: 8) {
                if analysisVM.isLoading, let image = selectedImage {
                    LoadingFoodRow(image: image)
                }

                if entries.isEmpty, !analysisVM.isLoading {
                    FoodEntryEmptyList()
                } else {
                    ForEach(entries, id: \.id) { entry in
                        FoodEntryRow(item: entry)
                            .onTapGesture {
                                hideFloatingButton = true
                                selectedFoodEntry = entry
                            }
                    }
                }
            }
        }
        .frame(width: 330, alignment: .leading)
        .navigationDestination(item: $selectedFoodEntry) { entry in
            FoodEntryDetails(item: entry, hideFloatingButton: $hideFloatingButton)
        }
        .onChange(of: selectedFoodEntry) { _, newValue in
            if newValue == nil {
                hideFloatingButton = false
            }
        }
        .onChange(of: selectedDate) { _, _ in
            if entries.isEmpty, !analysisVM.isLoading {
                logger.info("No food entry found")
            }
        }
    }
}

struct FoodEntryEmptyList: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.1))
            .overlay {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You haven't uploaded any food yet.")
                        .font(.callout)
                        .bold()
                    Text(
                        "Start tracking today's meals by taking a quick picture."
                    )
                }
            }
            .frame(width: 330, height: 120)
            .padding(8)
    }
}

struct FoodEntryRow: View {
    @Bindable var item: NutritionModel

    private var calculatedCalories: String {
        guard let base = Double(item.nutrients.calories) else { return item.nutrients.calories }
        return String(format: "%.0f", base * item.servingMultiplier)
    }

    private func calculateNutrient(_ nutrient: NutritionModel.StoredNutrient) -> String {
        let calculated = nutrient.total * item.servingMultiplier
        return "\(calculated.cleanString())\(nutrient.unit)"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.1))
            .overlay {
                HStack {
                    if let image = item.image {
                        FoodImage(image: image)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(item.foodName)
                                .fontWeight(.regular)
                                .font(.system(size: 16))
                            Spacer()
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay {
                                    Text(item.createdAt, style: .time)
                                        .fontWeight(.regular)
                                        .font(.system(size: 12))
                                }
                                .frame(width: 54, height: 28)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("\(calculatedCalories) calories")
                        }
                        .bold()
                        Spacer()
                        HStack {
                            FoodNutriView(nutrition:
                                calculateNutrient(item.nutrients.protein), image: "🍗")

                            FoodNutriView(nutrition: calculateNutrient(item.nutrients.carbs), image: "🌾")

                            FoodNutriView(nutrition:
                                calculateNutrient(item.nutrients.fats), image: "🥑")
                        }
                    }
                    .padding(.top)
                    .padding(.bottom)
                    .padding()
                }
            }
            .frame(width: 330, height: 120)
            .padding(8)
    }
}
