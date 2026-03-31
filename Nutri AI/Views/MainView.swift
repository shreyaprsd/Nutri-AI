//
//  MainView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: AuthViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    @State private var floatingButtonVisibilty = FloatingButtonVisibility()
    @State private var analysisVM = NutrientAnalysisViewModel()
    @State var foodViewModel: FoodEntryViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(
                    selectedDate: $selectedDate,
                    analysisVM: analysisVM
                )
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                NavigationStack {
                    GrowthView()
                }
                .tabItem {
                    Label(
                        "Progress",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                }
                .tag(1)
                NavigationStack {
                    ProfileView(auth: viewModel, foodViewModel: foodViewModel)
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
            }
            if !floatingButtonVisibilty.isHidden {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showImagePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(theme.buttonBackground)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "camera")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(theme.buttonForeground)
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            CameraView(image: $selectedImage)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { _, newValue in
            guard let image = newValue else { return }
            selectedTab = 0
            selectedImage = nil // clear immediately
            Task {
                await analysisVM.analyzeFood(image: image, modelContext: modelContext)
            }
        }
        .environment(floatingButtonVisibilty)
    }
}
