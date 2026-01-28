//
//  DesiredWeightView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/01/26.
// 6 onboarding screen

import SwiftData
import SwiftUI

struct DesiredWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @State var weight: Double = 54.0
    @State private var selectedGoal: Goal?
    @ObservedObject var authViewModel: AuthViewModel
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

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
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
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

    struct WeightSelectorView: View {
        @Binding var weight: Double
        @State private var isEditing = false
        @FocusState private var isFocused: Bool

        let minWeight: Double = 30.0
        let maxWeight: Double = 200.0
        let step: Double = 0.5

        var body: some View {
            HStack {
                Button {
                    isEditing = false
                    isFocused = false
                    incrementWeight()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                }
                .padding(20)
                if isEditing {
                    TextField("", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 32, weight: .regular))
                        .frame(width: 70)
                        .focused($isFocused)
                } else {
                    Button {
                        isEditing = true
                        isFocused = true
                    } label: {
                        Text("\(String(format: "%.1f", weight))")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(Color.black)
                            .frame(width: 70)
                    }
                }

                Button {
                    isFocused = false
                    isEditing = false
                    decrementWeight()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                }
                .padding(20)
            }
        }

        private func incrementWeight() {
            if weight + step <= maxWeight {
                weight += step
            }
        }

        private func decrementWeight() {
            if weight - step >= minWeight {
                weight -= step
            }
        }
    }

    private func saveData() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        viewModel.saveDesiredWeight(weight)
    }

    private func loadSavedData() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        if let userInfo = viewModel.loadUserInfo() {
            if userInfo.desiredWeightInKg > 0 {
                weight = userInfo.desiredWeightInKg
            }
            selectedGoal = userInfo.desiredGoal
        }
    }
}
