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
    @EnvironmentObject private var cardsStore: MacroCardsStore

    private var filteredEntries: [NutritionModel] {
        foodEntries.entries(for: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WeeklyCalendarView(selectedDate: $selectedDate)
                    DayWiseCalorieCard(
                        nutrientType: nutrientType[0],
                        ringColor: nutrientType[0].ringColor,
                        nutrientIcon: nutrientType[0].icon,
                        cardHeight: 132,
                        cardWidth: 330
                    )
                    HStack(spacing: 8) {
                        DayWiseMacroCards(
                            nutrientType: nutrientType[1],
                            ringColor: nutrientType[1].ringColor,
                            nutrientIcon: nutrientType[1].icon,
                            cardHeight: 132,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
                            nutrientType: nutrientType[2],
                            ringColor: nutrientType[2].ringColor,
                            nutrientIcon: nutrientType[2].icon,
                            cardHeight: 132,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
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
            let viewModel = FoodEntryViewModel(modelContext: modelContext)
            await viewModel.refreshEntries(for: selectedDate)
        }
        .onAppear {
            cardsStore.foodEntries = foodEntries
            cardsStore.users = users
            cardsStore.selectedDate = selectedDate
        }
        .onChange(of: foodEntries) { _, newValue in
            cardsStore.foodEntries = newValue
        }
        .onChange(of: foodEntries.map(\.servingMultiplier)) { _, _ in
            cardsStore.foodEntries = foodEntries
        }
        .onChange(of: users) { _, newValue in
            cardsStore.users = newValue
        }
        .onChange(of: selectedDate) { _, newValue in
            cardsStore.selectedDate = newValue
        }
    }
}
