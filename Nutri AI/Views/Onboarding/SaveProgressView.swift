//
//  SaveProgressView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import SwiftData
import SwiftUI

struct SaveProgressView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(viewModel: AuthViewModel, currentOnboardingStep: Int = 11, totalOnboardingSteps: Int = 12) {
        self.viewModel = viewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack {
            if viewModel.authenticationState == .authenticated {
                VStack(spacing: 20) {
                    Text("Save your progress")
                        .font(.system(size: 36, weight: .medium))
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("Account Linked Successfully")
                        .font(.headline)
                    Spacer()
                }

                Spacer()

                Button {
                    NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                } label: {
                    Text("Finish Setup")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 310, height: 46)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black))
                }
                .padding(.bottom, 20)

            } else {
                Text("Save your progress")
                    .font(.system(size: 36, weight: .medium))
                Spacer()
                LoginView(viewModel: viewModel)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
        .onChange(of: viewModel.authenticationState) { _, newValue in
            if newValue == .authenticated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                }
            }
        }
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
