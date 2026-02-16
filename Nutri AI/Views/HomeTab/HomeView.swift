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
    private var foodEntryViewModel: FoodEntryViewModel {
        FoodEntryViewModel(modelContext: modelContext)
    }

    private var filteredEntries: [NutritionModel] {
        let calendar = Calendar.current
        return foodEntries.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    WeeklyCalendarView(selectedDate: $selectedDate)
                    DayWiseCalorieCard(
                        selectedDate: $selectedDate,
                        nutrientType: nutrientType[0],
                        ringColor: nutrientType[0].ringColor,
                        nutrientIcon: nutrientType[0].icon,
                        cardHeight: 124,
                        cardWidth: 330
                    )
                    HStack(spacing: 8) {
                        DayWiseMacroCards(
                            selectedDate: $selectedDate,
                            nutrientType: nutrientType[1],
                            ringColor: nutrientType[1].ringColor,
                            nutrientIcon: nutrientType[1].icon,
                            cardHeight: 128,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
                            selectedDate: $selectedDate,
                            nutrientType: nutrientType[2],
                            ringColor: nutrientType[2].ringColor,
                            nutrientIcon: nutrientType[2].icon,
                            cardHeight: 128,
                            cardWidth: 104
                        )
                        DayWiseMacroCards(
                            selectedDate: $selectedDate,
                            nutrientType: nutrientType[3],
                            ringColor: nutrientType[3].ringColor,
                            nutrientIcon: nutrientType[3].icon,
                            cardHeight: 128,
                            cardWidth: 104
                        )
                    }
                    .frame(width: 330)
                    FoodEntryList(
                        selectedImage: $selectedImage,
                        selectedDate: $selectedDate, analysisVM: analysisVM,
                        hideFloatingButton: $hideFloatingButton
                    )
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        Image(systemName: "carrot.fill")
                        Text("Nutri AI")
                    }
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 20)
                    .padding(.trailing, 240)
                    .padding(.bottom, 8)
                    .background(.clear)
                }
            }
        }
        .task(id: selectedDate) {
            await foodEntryViewModel.refreshEntries(for: selectedDate)
        }
    }
}

#Preview {
    HomeView(
        selectedDate: .constant(Date()), selectedImage: .constant(nil),
        analysisVM: NutrientAnalysisViewModel(),
        hideFloatingButton: .constant(false)
    )
}
