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
    @Binding var hideFloatingButton: Bool
    @Environment(\.modelContext) private var modelContext
    let nutrientType: [NutrientType] = [.calories, .protein, .carbs, .fats]

    private var filteredEntries: [NutritionModel] {
        foodEntries.entries(for: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WeeklyCalendarView(selectedDate: $selectedDate)
                    DayWiseCalorieCard(
                        data: macroData(for: .calories),
                        nutrientType: nutrientType[0],
                        ringColor: nutrientType[0].ringColor,
                        nutrientIcon: nutrientType[0].icon,
                        cardHeight: 132,
                        cardWidth: 330
                    )
                    HStack(spacing: 8) {
                        DayWiseMacroCards(
                            data: macroData(for: .protein),
                            nutrientType: nutrientType[1],
                            ringColor: nutrientType[1].ringColor,
                            nutrientIcon: nutrientType[1].icon,
                            cardHeight: 132,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
                            data: macroData(for: .carbs),
                            nutrientType: nutrientType[2],
                            ringColor: nutrientType[2].ringColor,
                            nutrientIcon: nutrientType[2].icon,
                            cardHeight: 132,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
                            data: macroData(for: .fats),
                            nutrientType: nutrientType[3],
                            ringColor: nutrientType[3].ringColor,
                            nutrientIcon: nutrientType[3].icon,
                            cardHeight: 132,
                            cardWidth: 104
                        )
                    }
                    .frame(width: 330)
                    FoodEntryList(
                        selectedImage: $selectedImage,
                        selectedDate: $selectedDate, analysisVM: analysisVM,
                        hideFloatingButton: $hideFloatingButton
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
            let viewModel = FoodEntryViewModel(modelContext: modelContext)
            await viewModel.refreshEntries(for: selectedDate)
        }
    }

    private func macroData(for type: NutrientType) -> MacroCardsData {
        MacroCardsData(foodEntries: foodEntries, users: users, nutrientType: type, selectedDate: selectedDate)
    }
}
