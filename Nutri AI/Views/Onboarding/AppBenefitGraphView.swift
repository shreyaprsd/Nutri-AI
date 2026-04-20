//
//  AppBenefitGraphView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 18/01/26.
// 8 onboarding screen

import SwiftUI

struct AppBenefitGraphView: View {
    @Environment(\.appTheme) private var theme
    @ObservedObject var authViewModel: AuthViewModel
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 8, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ComparisonGraphView()
            Spacer()
        }

        NavigationLink(destination: AllDoneView(authViewModel: authViewModel)) {
            PrimaryButton(title: "Continue")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
    }
}

struct ComparisonGraphView: View {
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Without\nNutri AI")
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(height: 45)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.cardBackground)
                                .frame(width: 145, height: 265)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray4))

                                Text("20%")
                                    .font(.system(size: 28, weight: .bold))
                            }
                            .frame(width: 145, height: 85)
                        }
                    }

                    VStack(spacing: 10) {
                        Text("With\nNutri AI")
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(height: 45)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.cardBackground)
                                .frame(width: 145, height: 265)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.primaryFill)

                                Text("2X")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(theme.primaryFillContent)
                            }
                            .frame(width: 145, height: 225)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                .padding(.bottom, 30)

                Text("Nutri AI makes it easy and holds\nyou accountable.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 35)
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 25)
        }
    }
}
