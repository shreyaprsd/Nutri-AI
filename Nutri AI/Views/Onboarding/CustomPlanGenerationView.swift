//
//  CustomPlanGenerationView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import SwiftUI
internal import Combine
import SwiftData

struct CustomPlanGenerationView: View {
    @State private var animationId = UUID()
    @State private var navigateToNextScreen: Bool = false
    @Environment(\.modelContext) var modelContext
    @ObservedObject var authViewModel: AuthViewModel
    let setupItems = [
        "Calories",
        "Carbs",
        "Protein",
        "Fats",
    ]

    var body: some View {
        VStack {
            Text("""
            We're setting everything for you 
            """)
            .font(.system(size: 40, weight: .medium))

            AnimatedLoadingComponent()
                .id(animationId)

            VStack(alignment: .leading, spacing: 20) {
                Text("Daily recommendation for")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)

                ForEach(Array(setupItems.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text("• \(item)")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)

                        Spacer()

                        if index < item.count {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationDestination(isPresented: $navigateToNextScreen) {
            CustomDailyPlanView(authViewModel: authViewModel)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            calculateNutrition()
            animationId = UUID()
            try? await Task.sleep(nanoseconds: 8_000_000_000)

            if !Task.isCancelled {
                navigateToNextScreen = true
            }
        }
    }

    private func calculateNutrition() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        viewModel.calculateAndSaveNutrition()
    }
}

struct AnimatedLoadingComponent: View {
    @State private var progress: CGFloat = 0.0
    @State private var currentMessage: String = "Customizing health plan..."

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let totalDuration: TimeInterval = 8.0

    var body: some View {
        VStack(spacing: 40) {
            HorizontalProgressBar(progress: progress)
                .frame(height: 8)
                .padding(.horizontal, 40)

            Text(currentMessage)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(height: 50)
        }
        .padding()
        .onReceive(timer) { _ in
            if progress < 1.0 {
                progress += 0.0125
            }

            if progress >= 0.25, progress < 0.26, currentMessage == "Customizing health plan..." {
                currentMessage = "Applying BMR formula..."
            } else if progress >= 0.50, progress < 0.51, currentMessage == "Applying BMR formula..." {
                currentMessage = "Estimating your metabolic age..."
            } else if progress >= 0.75, progress < 0.76, currentMessage == "Estimating your metabolic age..." {
                currentMessage = "Finalizing results..."
            }
        }
        .onAppear {
            currentMessage = "Customizing health plan..."
        }
    }
}

struct HorizontalProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.45, blue: 0.50),
                        Color(red: 0.55, green: 0.50, blue: 0.85),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: progress * geometry.size.width)
                .cornerRadius(10)
                .animation(.easeInOut, value: progress)
            }
        }
    }
}
