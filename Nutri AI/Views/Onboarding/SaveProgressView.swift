//
//  SaveProgressView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import SwiftData
import SwiftUI

struct SaveProgressView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(OnboardingState.self) private var onboardingState
    @State private var userInfoViewModel: UserInfoViewModel?
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

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 11, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack {
            if authViewModel.authenticationState == .authenticated {
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
                    onboardingState.isCompleted = true
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
                LoginView(viewModel: authViewModel)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }

        .onChange(of: authViewModel.authenticationState) { _, newValue in
            if newValue == .authenticated {
                Task {
                    await viewModel.uploadLocalData()

                    await MainActor.run {
                        onboardingState.isCompleted = true
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
