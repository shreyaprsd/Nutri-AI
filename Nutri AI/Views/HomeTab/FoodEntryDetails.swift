//
//  FoodEntryDetails.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 25/11/25.
//

import OSLog
import SwiftData
import SwiftUI

struct FoodEntryDetails: View {
    let item: NutritionModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility
    private var vm: FoodEntryViewModel {
        FoodEntryViewModel(modelContext: modelContext)
    }

    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "FoodEntryDetails")

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.vertical, showsIndicators: false) {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .padding(.bottom, 24)
                }
                FoodEntryTextDetailsView(item: item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nutrition")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Delete Food", role: .destructive) {
                            Task {
                                try await vm.deleteFoodEntry(item)
                                dismiss()

                                let descriptor = FetchDescriptor<
                                    NutritionModel
                                >()
                                let count = try? modelContext.fetchCount(
                                    descriptor
                                )
                                if count == 0 {
                                    floatingButtonVisibility.isHidden = false
                                }
                            }
                            logger.info("Food Item deleted")
                        }
                        Divider()
                        Button("Save Image") {
                            if let image = item.image {
                                let imageSaver = ImageSaver()
                                imageSaver.writeToPhotoAlbum(image: image)
                            }
                            logger.info("Food Image Saved to the photo's library")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

struct FoodEntryTextDetailsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var inputText = ""
    @State private var isExpanding = false
    @State private var updateTask: Task<Void, Never>?
    @Bindable var item: NutritionModel
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isTextFieldFocused: Bool

    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "FoodEntryTextDetails")
    private var vm: FoodEntryViewModel {
        FoodEntryViewModel(modelContext: modelContext)
    }

    private var calculatedCalories: String {
        guard let base = Double(item.nutrients.calories) else {
            return item.nutrients.calories
        }
        return String(format: "%.0f", base * item.servingMultiplier)
    }

    private func calculateNutrient(_ nutrient: NutritionModel.StoredNutrient)
        -> String
    {
        let calculated = nutrient.total * item.servingMultiplier
        return "\(calculated.cleanString())\(nutrient.unit)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.border, lineWidth: 1)
                .overlay {
                    Text(item.createdAt, style: .time)
                        .fontWeight(.regular)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.buttonBackground)
                }
                .frame(width: 54, height: 28)

            HStack {
                Text(item.foodName)
                    .font(.system(size: 20, weight: .medium))
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.border, lineWidth: 1)
                    .overlay {
                        HStack {
                            TextField("1.0", text: $inputText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .focused($isTextFieldFocused)
                                .onAppear {
                                    inputText = String(
                                        format: "%.1f",
                                        item.servingMultiplier
                                    )
                                }
                                .onChange(of: inputText) { _, newValue in
                                    updateTask?.cancel()
                                    if !newValue.isEmpty,
                                       Double(newValue) != nil
                                    {
                                        updateTask = Task {
                                            try? await Task.sleep(
                                                nanoseconds: 1_000_000_000
                                            )
                                            if !Task.isCancelled {
                                                await updateNutrients()
                                            }
                                        }
                                    }
                                }
                                .onSubmit {
                                    updateTask?.cancel()
                                    Task {
                                        await updateNutrients()
                                    }
                                }
                            Image(systemName: "pencil")
                        }
                        .padding()
                    }
                    .frame(width: 125, height: 38)
            }
            .padding(.bottom, 38)

            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.border, lineWidth: 1)
                    .overlay {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 32))
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.system(size: 14, weight: .thin))
                                Text(calculatedCalories)
                                    .font(.system(size: 24, weight: .heavy))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .frame(width: 329, height: 78)
            }

            HStack {
                VStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.border, lineWidth: 1)
                        .overlay {
                            HStack {
                                Text("🍗")
                                    .font(.system(size: 16))
                                VStack(alignment: .center) {
                                    Text("Proteins")
                                        .font(.system(size: 14, weight: .thin))
                                    Text(
                                        calculateNutrient(
                                            item.nutrients.protein
                                        )
                                    )
                                    .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                        .frame(width: 105, height: 60)
                }
                VStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.border, lineWidth: 1)
                        .overlay {
                            HStack {
                                Text("🌾")
                                    .font(.system(size: 16))
                                VStack(alignment: .center) {
                                    Text("Carbs")
                                        .font(.system(size: 14, weight: .thin))
                                    Text(
                                        calculateNutrient(item.nutrients.carbs)
                                    )
                                    .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                        .frame(width: 105, height: 60)
                }
                VStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.border, lineWidth: 1)
                        .overlay {
                            HStack {
                                Text("🥑")
                                    .font(.system(size: 16))
                                VStack(alignment: .center) {
                                    Text("Fats")
                                        .font(.system(size: 14, weight: .thin))
                                    Text(calculateNutrient(item.nutrients.fats))
                                        .font(
                                            .system(size: 14, weight: .semibold)
                                        )
                                }
                            }
                        }
                        .frame(width: 105, height: 60)
                }
            }
            .padding(.bottom, 54)

            VStack {
                HStack {
                    Text("Other nutritional facts")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Button {
                        withAnimation {
                            isExpanding.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(theme.buttonBackground)
                            .rotationEffect(.degrees(isExpanding ? 90 : 0))
                    }
                }
                if isExpanding {
                    VStack(spacing: 8) {
                        FoodNutriFactRow(
                            label: "Saturated Fat",
                            value: calculateNutrient(
                                item.nutrients.saturatedFats
                            )
                        )
                        FoodNutriFactRow(
                            label: "Polysaturated Fat",
                            value: calculateNutrient(
                                item.nutrients.polyunsaturatedFats
                            )
                        )
                        FoodNutriFactRow(
                            label: "Cholestrol",
                            value: calculateNutrient(item.nutrients.cholesterol)
                        )
                        FoodNutriFactRow(
                            label: "Sodium",
                            value: calculateNutrient(item.nutrients.sodium)
                        )
                        FoodNutriFactRow(
                            label: "Pottasium",
                            value: calculateNutrient(item.nutrients.potassium)
                        )
                        FoodNutriFactRow(
                            label: "Vitamin A",
                            value: calculateNutrient(item.nutrients.vitaminA)
                        )
                        FoodNutriFactRow(
                            label: "Vitamin C",
                            value: calculateNutrient(item.nutrients.vitaminC)
                        )
                        FoodNutriFactRow(
                            label: "Calcium",
                            value: calculateNutrient(item.nutrients.calcium)
                        )
                        FoodNutriFactRow(
                            label: "Iron",
                            value: calculateNutrient(item.nutrients.iron)
                        )
                        FoodNutriFactRow(
                            label: "Fiber",
                            value: calculateNutrient(item.nutrients.fiber)
                        )
                        FoodNutriFactRow(
                            label: "Sugar",
                            value: calculateNutrient(item.nutrients.sugar)
                        )
                    }
                }
            }
        }
        .onTapGesture {
            Task {
                updateTask?.cancel()
                if !inputText.isEmpty, Double(inputText) != nil {
                    await updateNutrients()
                }
                isTextFieldFocused = false
            }
        }
    }

    private func updateNutrients() async {
        guard let multiplier = Double(inputText), multiplier > 0 else {
            return
        }
        do {
            try await vm.updateServingMultiplier(
                for: item,
                multiplier: multiplier
            )

        } catch {
            logger.error("Error saving:  the new serving quantity\(error)")
        }
    }
}

struct FoodNutriFactRow: View {
    @Environment(AppTheme.self) private var theme
    let label: String
    let value: String
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(theme.border, lineWidth: 1)
            .overlay {
                HStack {
                    Text(label)
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                }
                .padding()
            }
            .frame(width: 328, height: 46)
    }
}
