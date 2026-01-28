//
//  CustomDailyPlanView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import SwiftData
import SwiftUI

struct CustomDailyPlanView: View {
    @Query private var users: [UserInfoModel]
    @Environment(\.modelContext) var modelContext
    @ObservedObject var authViewModel: AuthViewModel
    @State private var caloriesValue: Double = 0.0
    @State private var carbsValue: Double = 0.0
    @State private var proteinValue: Double = 0.0
    @State private var fatsValue: Double = 0.0

    private var gridColumn = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(
        authViewModel: AuthViewModel,
        currentOnboardingStep: Int = 9,
        totalOnboardingSteps: Int = 12
    ) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack {
            title
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 360, height: 450)
                    .foregroundStyle(Color.gray.opacity(0.1))
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Daily recommendation")
                                .font(.system(size: 24, weight: .semibold))
                                .padding(.bottom, 4)
                            Text("You can edit this anytime")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                    Spacer()

                    LazyVGrid(columns: gridColumn, spacing: 16) {
                        NutritionCard(
                            nutrientType: .calories,
                            nutrientValue: $caloriesValue
                        )

                        NutritionCard(
                            nutrientType: .carbs,
                            nutrientValue: $carbsValue
                        )

                        NutritionCard(
                            nutrientType: .protein,
                            nutrientValue: $proteinValue
                        )

                        NutritionCard(
                            nutrientType: .fats,
                            nutrientValue: $fatsValue
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(width: 350, height: 450)
            }

            Spacer()

            NavigationLink(destination: SaveProgressView(viewModel: authViewModel)) {
                Text("Let's get started!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                    )
            }
        }
        .onAppear {
            loadValues()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
        .onChange(of: authViewModel.authenticationState) { _, newValue in
            if newValue == .authenticated {
                NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
            }
        }
    }

    private var title: some View {
        VStack(alignment: .center) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36, weight: .medium))
            Text("Congratulations \nYour custom plan is ready!")
                .font(.system(size: 36, weight: .medium))
        }
    }

    private func loadValues() {
        guard let user = users.first else { return }

        caloriesValue = user.calculations?.targetDailyCalories ?? 0.0
        carbsValue = user.calculations?.macros.carbs ?? 0.0
        proteinValue = user.calculations?.macros.protein ?? 0.0
        fatsValue = user.calculations?.macros.fats ?? 0.0
    }
}
