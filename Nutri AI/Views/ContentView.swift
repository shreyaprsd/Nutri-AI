//
//  ContentView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State var foodEntryViewModel: FoodEntryViewModel

    var body: some View {
        VStack {
            switch viewModel.authenticationState {
            case .unauthenticated:
                LoginView(viewModel: viewModel)
            case .authenticating:
                ProgressView("Signing in ..")
                    .progressViewStyle(CircularProgressViewStyle())
            case .authenticated:
                MainView(viewModel: viewModel, foodViewModel: foodEntryViewModel)
            }
        }
        .onAppear {
            viewModel.registerAuthStateHandler()
        }
    }
}
