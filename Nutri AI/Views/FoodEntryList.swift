//
//  FoodEntryList.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import SwiftData
import SwiftUI

struct FoodEntryList: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries:
        [NutritionModel]
    @Binding var selectedImage: UIImage?
    var geminiVM: GeminiViewModel
    @State private var imageID = UUID()
    @State private var selectedFoodEntry: NutritionModel?
    @Environment(\.modelContext) private var modelContext
    @Binding var hideFloatingButton: Bool
    var body: some View {
        Group {
            if foodEntries.isEmpty, !geminiVM.isLoading {
                FoodEntryEmptyList()
            } else {
                List {
                    if geminiVM.isLoading, let image = selectedImage {
                        LoadingFoodRow(image: image)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                    ForEach(foodEntries, id: \.id) { entry in
                        FoodEntryRow(item: entry)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .onTapGesture {
                                hideFloatingButton = true
                                selectedFoodEntry = entry
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
                .navigationDestination(item: $selectedFoodEntry) { entry in
                    FoodEntryDetails(item: entry)
                }
                .onChange(of: selectedFoodEntry) { _, newValue in
                    if newValue == nil {
                        hideFloatingButton = false
                    }
                }
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
            .padding(.top, 478)
            .padding(.bottom, 116)
    }
}

struct FoodEntryRow: View {
    @Bindable var item: NutritionModel

    private var calculatedCalories: String {
        guard let base = Double(item.calories) else { return item.calories }
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
                                calculateNutrient(item.protein), image: "🍗")

                            FoodNutriView(nutrition: calculateNutrient(item.carbs), image: "🌾")

                            FoodNutriView(nutrition:
                                calculateNutrient(item.fats), image: "🥑")
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
