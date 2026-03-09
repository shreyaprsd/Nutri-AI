//
// ContentView.swift
// Nutri AI
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State var foodEntryViewModel: FoodEntryViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var hasCompletedOnboarding = false
    @State private var isCheckingOnboardingStatus = true
    @State private var justFinishedOnboarding = false
    @State private var userInfoViewModel: UserInfoViewModel?
    @Environment(OnboardingState.self) private var onboardingState

    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }
        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    var body: some View {
        VStack {
            switch authViewModel.authenticationState {
            case .unauthenticated:
                NavigationStack {
                    NewUserOnboardingView(authViewModel: authViewModel)
                }
            case .authenticating:
                ProgressView("Signing in...")
                    .progressViewStyle(CircularProgressViewStyle())
            case .authenticated:
                if isCheckingOnboardingStatus {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            checkOnboardingStatus()
                        }
                } else if hasCompletedOnboarding {
                    MainView(viewModel: authViewModel, foodViewModel: foodEntryViewModel)
                } else {
                    NavigationStack {
                        GenderView(authViewModel: authViewModel)
                    }
                }
            }
        }
        .onAppear {
            authViewModel.registerAuthStateHandler()
        }
        .onChange(of: authViewModel.authenticationState) { _, newValue in
            if newValue == .authenticated {
                markUserStartedOnboarding()

                if justFinishedOnboarding {
                    hasCompletedOnboarding = true
                    isCheckingOnboardingStatus = false
                } else {
                    isCheckingOnboardingStatus = true
                    checkOnboardingStatus()
                }
            } else if newValue == .unauthenticated {
                isCheckingOnboardingStatus = true
                hasCompletedOnboarding = false
                justFinishedOnboarding = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            justFinishedOnboarding = true
            hasCompletedOnboarding = true
            isCheckingOnboardingStatus = false
        }
    }

    private func checkOnboardingStatus() {
        let userInfo = viewModel.loadUserInfo()

        if let userInfo, userInfo.calculations != nil {
            hasCompletedOnboarding = true
        } else {
            hasCompletedOnboarding = false
        }
        isCheckingOnboardingStatus = false
    }

    private func hasUserStartedOnboardingOnThisDevice() -> Bool {
        UserDefaults.standard.bool(forKey: "hasStartedOnboarding")
    }

    private func markUserStartedOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasStartedOnboarding")
    }
}
