//
//  GoalMotivationView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 18/01/26.
// 7 onboarding screen

import SwiftData
import SwiftUI

struct GoalMotivationView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    @State private var goal: Goal?
    @State private var currentWeight = 0.0
    @State private var desiredWeight = 0.0
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

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 7, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    private var weightDifference: Double {
        abs(desiredWeight - currentWeight)
    }

    private var goalVerb: String {
        guard let goal else { return "Losing" }
        switch goal {
        case .weightLoss:
            return "Losing"
        case .weightGain:
            return "Gaining"
        case .maintain:
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("\(goalVerb) ")
                        .font(.system(size: 32, weight: .semibold))

                    Text("\(String(format: "%.1f", weightDifference)) kg")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.85, green: 0.6, blue: 0.4))

                    Text(" is a")
                        .font(.system(size: 32, weight: .semibold))
                }

                Text("realistic target. It's")
                    .font(.system(size: 32, weight: .semibold))

                Text("not hard at all!")
                    .font(.system(size: 32, weight: .semibold))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)

            Text("90% of the users say that the change is obvious after using Nutri AI and it is not easy to rebound")
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 20)

            Spacer()

            NavigationLink(destination: AppBenefitGraphView(authViewModel: authViewModel)) {
                Text("Continue")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.buttonForeground)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.buttonBackground)
                    )
            }
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

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            goal = userInfo.desiredGoal
            currentWeight = userInfo.weightInKg
            desiredWeight = userInfo.desiredWeightInKg
        }
    }
}
