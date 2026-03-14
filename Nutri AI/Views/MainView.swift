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
    @State private var imageID = UUID()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(
                    selectedDate: $selectedDate, selectedImage: $selectedImage,
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
                                    .fill(Color.black)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "camera")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
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
        .task(id: imageID) {
            if let selectedImage {
                await analysisVM.analyzeFood(image: selectedImage, modelContext: modelContext) {
                    self.selectedImage = nil
                }
            }
        }

        .onChange(of: selectedImage) { _, newValue in
            if newValue != nil {
                imageID = UUID()
                selectedTab = 0
            }
        }
        .environment(floatingButtonVisibilty)
    }
}
