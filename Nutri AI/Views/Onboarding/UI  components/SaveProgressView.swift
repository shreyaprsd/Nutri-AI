//
//  SaveProgressView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import SwiftUI

struct SaveProgressView: View {
    @StateObject var viewModel = AuthViewModel()
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(currentOnboardingStep: Int = 11, totalOnboardingSteps: Int = 12) {
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack {
            Text("Save your progress")
                .font(.system(size: 36, weight: .medium))
            Spacer()
            LoginView(viewModel: viewModel)
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
    }
}
