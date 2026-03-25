//
//  HomeView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries:
        [NutritionModel]
    @Query private var users: [UserInfoModel]
    @Binding var selectedDate: Date
    @Binding var selectedImage: UIImage?
    var analysisVM: NutrientAnalysisViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility

    let nutrientTypes: [NutrientType] = [.calories, .protein, .carbs, .fats]

    private var filteredEntries: [NutritionModel] {
        foodEntries.entries(for: selectedDate)
    }

    private var foodEntryViewModel: FoodEntryViewModel {
        FoodEntryViewModel(modelContext: modelContext)
    }

    private let macroTypes: [NutrientType] = [.protein, .carbs, .fats]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WeeklyCalendarView(selectedDate: $selectedDate)
                    DayWiseCalorieCard(
                        data: macroData(for: .calories),
                        nutrientType: nutrientTypes[0],
                        cardHeight: 132,
                        cardWidth: 330
                    )
                    HStack(spacing: 8) {
                        ForEach(macroTypes, id: \.self) { type in
                            DayWiseMacroCards(
                                data: macroData(for: type),
                                nutrientType: type,
                                ringColor: type.ringColor,
                                nutrientIcon: type.icon,
                                cardHeight: 132,
                                cardWidth: 104
                            )
                        }
                    }
                    .frame(width: 330)
                    FoodEntryList(
                        entries: filteredEntries,
                        selectedImage: $selectedImage,
                        selectedDate: $selectedDate, analysisVM: analysisVM
                    )
                    .padding(.top, 4)
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        Image(systemName: "carrot.fill")
                        Text("Nutri AI")
                        Spacer()
                    }
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    .background(.clear)
                }
            }
        }
        .task(id: selectedDate) {
            // Only refresh if local data is empty for this date
            guard filteredEntries.isEmpty else { return }
            await foodEntryViewModel.refreshEntries(for: selectedDate)
        }
        .onAppear {
            floatingButtonVisibility.isHidden = false
        }
    }

    private func macroData(for type: NutrientType) -> MacroCardsData {
        MacroCardsData(foodEntries: foodEntries, users: users, nutrientType: type, selectedDate: selectedDate)
    }
}
