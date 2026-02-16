//
//  Nutri_AIApp.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import BackgroundTasks
import FirebaseAuth
import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        let hasStartedOnboarding = UserDefaults.standard.bool(forKey: "hasStartedOnboarding")
        let hasPersistedAuth = Auth.auth().currentUser != nil

        if !hasStartedOnboarding, hasPersistedAuth {
            try? Auth.auth().signOut()
        }

        BackgroundSyncManager.shared.registerBackgroundTask()
        return true
    }
}

@main
struct Nutri_AIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel: AuthViewModel = .init()
    @State private var onboardingState = OnboardingState()
    @StateObject private var cardsStore = MacroCardsStore()

    var body: some Scene {
        WindowGroup {
            AppRootView(viewModel: viewModel)
                .environment(onboardingState)
                .environmentObject(cardsStore)
        }
        .modelContainer(for: [NutritionModel.self, UserInfoModel.self])
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ContentView(
            authViewModel: viewModel,
            foodEntryViewModel: FoodEntryViewModel(modelContext: modelContext)
        )
    }
}
