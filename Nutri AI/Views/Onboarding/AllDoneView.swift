//
//  AllDoneView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 18/01/26.
// 9 onboarding screen

import SwiftUI

struct AllDoneView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 9, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        AllDoneViewCard(authViewModel: authViewModel, currentOnboardingStep: currentOnboardingStep, totalOnboardingSteps: totalOnboardingSteps)
    }
}

struct AllDoneViewCard: View {
    @ObservedObject var authViewModel: AuthViewModel
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.8))
                    )

                Text("All done!")
                    .font(.system(size: 22, weight: .semibold))
            }
            .padding(.bottom, 20)

            VStack(spacing: 4) {
                Text("Time to generate")
                    .font(.system(size: 36, weight: .bold))

                Text("your custom plan!")
                    .font(.system(size: 36, weight: .bold))
            }
            .multilineTextAlignment(.center)

            Spacer()

            NavigationLink(destination: CustomPlanGenerationView(authViewModel: authViewModel)) {
                PrimaryButton(title: "Continue")
            }
            .padding(.bottom, 20)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
    }
}
