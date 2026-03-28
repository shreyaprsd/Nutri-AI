//
//  DesiredWeightView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/01/26.
// 6 onboarding screen

import SwiftData
import SwiftUI

struct DesiredWeightView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var modelContext
    @State var weight: Double = 54.0
    @State private var selectedGoal: Goal?
    @State private var userInfoViewModel: UserInfoViewModel?
    @ObservedObject var authViewModel: AuthViewModel
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }
        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 6, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("What is your desired weight?")
                .font(.system(size: 32, weight: .semibold))

            Spacer()

            if let goal = selectedGoal {
                Text(goal.rawValue)
                    .font(.system(size: 20, weight: .regular))
                    .padding(.bottom, 8)
            }

            WeightSelectorView(weight: $weight)

            Spacer()

            NavigationLink(destination: GoalMotivationView(authViewModel: authViewModel)) {
                Text("Continue")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.buttonForeground)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.buttonBackground)
                    )
            }
            .simultaneousGesture(TapGesture().onEnded {
                saveData()
            })
        }

        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
        .onAppear {
            loadSavedData()
        }
    }

    private func saveData() {
        viewModel.saveDesiredWeight(weight)
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            if userInfo.desiredWeightInKg > 0 {
                weight = userInfo.desiredWeightInKg
            }
            selectedGoal = userInfo.desiredGoal
        }
    }
}
