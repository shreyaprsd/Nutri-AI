//
//  GenderView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/01/26.
// 1 onboarding screen

import SwiftData
import SwiftUI

struct GenderView: View {
    @State private var selectedGender: Gender?
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

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 1, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Choose your Gender")
                .font(.system(size: 32, weight: .semibold))
            Text("This will be used to calibrate your custom plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }

        Spacer()

        GenderSelectionView(selectedGender: $selectedGender)

        Spacer()

        NavigationLink(destination: WorkoutFrequencyView(authViewModel: authViewModel)) {
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
            if let gender = selectedGender {
                saveData(gender)
            }
        })
        .disabled(selectedGender == nil)
        .opacity(selectedGender == nil ? 0.3 : 1.0)
        .padding(.bottom, 20)
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

    private func saveData(_ gender: Gender) {
        viewModel.saveGender(gender)
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            selectedGender = userInfo.gender
        }
    }
}
