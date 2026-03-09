//
//  WorkoutFrequencyView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/01/26.
// 2 onboarding screen

import SwiftData
import SwiftUI

struct WorkoutFrequencyView: View {
    @State private var selectedFrequency: WorkoutFrequency?
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

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 2, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("How many workouts do you do per week?")
                .font(.system(size: 32, weight: .semibold))
                .padding(12)
            Text("This will be used to calibrate your custom plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)

            Spacer()

            VStack {
                ForEach(WorkoutFrequency.allCases) { frequency in
                    WorkoutFrequencyCardview(frequency: frequency, isSelected: frequency == selectedFrequency)
                        .onTapGesture {
                            selectedFrequency = frequency
                        }
                }
            }

            Spacer()

            NavigationLink(destination: HeightWeightView(authViewModel: authViewModel)) {
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
                if let frequency = selectedFrequency {
                    saveData(frequency)
                }
            })
            .disabled(selectedFrequency == nil)
            .opacity(selectedFrequency == nil ? 0.3 : 1.0)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                        .frame(width: 300)
                }
            }
        }
        .onAppear {
            loadSavedData()
        }
    }

    private func saveData(_ frequency: WorkoutFrequency) {
        viewModel.saveWorkoutFrequency(frequency)
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            selectedFrequency = userInfo.workoutFrequency
        }
    }
}

struct WorkoutFrequencyCardview: View {
    let frequency: WorkoutFrequency
    let isSelected: Bool

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 30, height: 30)
                Image(systemName: frequency.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(frequency.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isSelected ? Color.white : Color.black)
                Text(frequency.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isSelected ? Color.white : Color.black)
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 310, height: 74)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? Color.black : Color.white)
        )
    }
}
