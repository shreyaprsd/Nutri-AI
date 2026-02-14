//
//  HomeView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selectedDate: Date
    @Binding var selectedImage: UIImage?
    var analysisVM: NutrientAnalysisViewModel
    @Binding var hideFloatingButton: Bool
    @Environment(\.modelContext) private var modelContext

    private var foodEntryViewModel: FoodEntryViewModel {
        FoodEntryViewModel(modelContext: modelContext)
    }

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    WeeklyCalendarView(selectedDate: $selectedDate)
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
