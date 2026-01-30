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
                        if let user = users.first {
                            NutritionCard(
                                nutrientType: .calories,
                                nutrientValue: Binding(
                                    get: { user.calculations?.targetDailyCalories ?? 0.0 },
                                    set: { newValue in
                                        let vm = UserInfoViewModel(modelContext: modelContext)
                                        vm.updateNutrient(nutrientType: .calories, value: newValue)
                                    }
                                )
                            )

                            NutritionCard(
                                nutrientType: .carbs,
                                nutrientValue: Binding(
                                    get: { user.calculations?.macros.carbs ?? 0.0 },
                                    set: { newValue in
                                        user.calculations?.macros.carbs = newValue
                                    }
                                )
                            )

                            NutritionCard(
                                nutrientType: .protein,
                                nutrientValue: Binding(
                                    get: { user.calculations?.macros.protein ?? 0.0 },
                                    set: { newValue in
                                        user.calculations?.macros.protein = newValue
                                    }
                                )
                            )

                            NutritionCard(
                                nutrientType: .fats,
                                nutrientValue: Binding(
                                    get: { user.calculations?.macros.fats ?? 0.0 },
                                    set: { newValue in
                                        user.calculations?.macros.fats = newValue
                                    }
                                )
                            )
                        }
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
            let infoViewModel = UserInfoViewModel(modelContext: modelContext)
            if users.first?.calculations == nil {
                infoViewModel.calculateAndSaveNutrition()
            }
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
}
