//
//  MainView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: AuthViewModel
    @State private var showOptions = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedTab = 0
    @State private var hideFloatingButton = false
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedImage: $selectedImage, hideFloatingButton: $hideFloatingButton)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                GrowthView()
                    .tabItem {
                        Label(
                            "Progress",
                            systemImage: "chart.line.uptrend.xyaxis"
                        )
                    }
                    .tag(1)
                ProfileView(auth: viewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }

            if showOptions {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showOptions = false
                    }
            }

            // Options Grid
            if showOptions {
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            OptionButton(
                                icon: "dumbbell",
                                title: "Log exercise"
                            ) {
                                showOptions = false
                                // Handle log exercise
                            }

                            OptionButton(
                                icon: "bookmark.fill",
                                title: "Saved foods"
                            ) {
                                showOptions = false
                                // Handle saved foods
                            }
                        }

                        HStack(spacing: 20) {
                            OptionButton(
                                icon: "magnifyingglass",
                                title: "Food Database"
                            ) {
                                showOptions = false
                                // Handle food database
                            }

                            OptionButton(
                                icon: "camera.viewfinder",
                                title: "Scan food"
                            ) {
                                showOptions = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    showImagePicker = true
                                }
                            }
                        }
                    }
                    .padding(30)
                    .background(Color.clear)
                    .transition(.move(edge: .bottom))
                    Spacer()
                        .frame(height: 150)
                }
            }
            if !hideFloatingButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                showOptions.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "plus")
                                    .font(.system(size: 30, weight: .medium))
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
        .onChange(of: selectedImage) { _, newValue in
            if newValue != nil {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainView(viewModel: AuthViewModel())
}
