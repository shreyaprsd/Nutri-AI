//
//  Nutri_AIApp.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import BackgroundTasks
import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        BackgroundSyncManager.shared.registerBackgroundTask()
        return true
    }
}

@main
struct Nutri_AIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel: AuthViewModel = .init()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .modelContainer(for: [NutritionModel.self])
    }
}
