//
// ContentView.swift
// Nutri AI
//  Created by Shreya Prasad on 05/11/25.
//

import FirebaseAuth
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
                            Task { await checkOnboardingStatus() }
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
                    Task { await checkOnboardingStatus() }
                }
            } else if newValue == .unauthenticated {
                isCheckingOnboardingStatus = true
                hasCompletedOnboarding = false
                justFinishedOnboarding = false
                onboardingState.isCompleted = false
                viewModel.clearLocalUserInfo()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            justFinishedOnboarding = true
            hasCompletedOnboarding = true
            isCheckingOnboardingStatus = false
        }
        .onChange(of: onboardingState.isCompleted) { _, isCompleted in
            if isCompleted {
                hasCompletedOnboarding = true
                isCheckingOnboardingStatus = false
            }
        }
    }

    private func checkOnboardingStatus() async {
        // If onboarding was already marked complete (e.g., via "Finish Setup" or notification), skip
        guard !hasCompletedOnboarding else {
            isCheckingOnboardingStatus = false
            return
        }

        // Detect user switch: if a different user signed in, clear stale local data
        let currentUserId = Auth.auth().currentUser?.uid
        let lastUserId = UserDefaults.standard.string(forKey: "lastSignedInUserId")

        if let lastUserId, lastUserId != currentUserId {
            viewModel.clearLocalUserInfo()
        }
        UserDefaults.standard.set(currentUserId, forKey: "lastSignedInUserId")

        let userInfo = viewModel.loadUserInfo()

        if let userInfo, userInfo.calculations != nil {
            // Fast path: local data exists (normal app launch, same user)
            hasCompletedOnboarding = true
        } else {
            // Slow path: try restoring from Firestore (reinstall scenario)
            let restored = await viewModel.restoreFromFirestore()
            hasCompletedOnboarding = restored
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
