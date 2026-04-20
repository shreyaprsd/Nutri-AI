//
//  DesiredGoalView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/01/26.
// 5 onboarding screen

import SwiftData
import SwiftUI

struct DesiredGoalView: View {
    @Environment(\.appTheme) private var theme
    @State private var selectedGoal: Goal?
    @Environment(\.modelContext) private var modelContext
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

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 5, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Text("What is your goal?")
                    .font(.system(size: 32, weight: .semibold))
                Text("This will be used to calibrate your custom plan.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack {
                ForEach(Goal.allCases, id: \.self) { goal in
                    Button(action: {
                        selectedGoal = goal
                    }) {
                        Text(goal.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedGoal == goal ? theme.primaryFillContent : .primary)
                            .frame(width: 310, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedGoal == goal ? theme.primaryFill : Color(.systemGray6)))
                    }
                }
            }

            Spacer()

            if selectedGoal == .maintain {
                NavigationLink(destination: AppBenefitGraphView(authViewModel: authViewModel)) {
                    PrimaryButton(title: "Continue")
                }
                .simultaneousGesture(TapGesture()
                    .onEnded {
                        if let goal = selectedGoal {
                            saveData(goal)
                        }
                    })
                .disabled(selectedGoal == nil)
                .opacity(selectedGoal == nil ? 0.3 : 1.0)
                .padding(.bottom, 20)
            } else {
                NavigationLink(destination: DesiredWeightView(authViewModel: authViewModel)) {
                    PrimaryButton(title: "Continue")
                }
                .simultaneousGesture(TapGesture()
                    .onEnded {
                        if let goal = selectedGoal {
                            saveData(goal)
                        }
                    })
                .disabled(selectedGoal == nil)
                .opacity(selectedGoal == nil ? 0.3 : 1.0)
                .padding(.bottom, 20)
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

    private func saveData(_ goal: Goal) {
        viewModel.saveDesiredGoal(goal)
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            selectedGoal = userInfo.desiredGoal
        }
    }
}
