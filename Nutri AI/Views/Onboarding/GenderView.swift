//
//  GenderView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/01/26.
// 1 onboarding screen

import SwiftData
import SwiftUI

struct GenderView: View {
    @State private var selectedGender: Gender?
    @Environment(\.modelContext) private var modelContext

    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    init(currentOnboardingStep: Int = 1, totalOnboardingSteps: Int = 12) {
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Choose your Gender")
                .font(.system(size: 32, weight: .semibold))
            Text("This will be used to calibrate your custom plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        
        Spacer()
        
        VStack {
            ForEach(Gender.allCases, id: \.self) {
                gender in
                Button(action: {
                    selectedGender = gender
                }) {
                    Text(gender.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedGender == gender ? .white : .primary)
                        .frame(width: 310, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGender == gender ? Color.black : Color(.systemGray6)))
                }
            }
        }
        
        Spacer()
        
        NavigationLink(destination: WorkoutFrequencyView()) {
            Text("Continue")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 310, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                )
        }
        .simultaneousGesture(TapGesture().onEnded {
            if let gender = selectedGender {
                saveData(gender)
            }
        })
        .disabled(selectedGender == nil)
        .opacity(selectedGender == nil ? 0.3 : 1.0)
        .padding(.bottom, 20)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressBar(current: currentOnboardingStep, total: totalOnboardingSteps)
                    .frame(width: 300)
            }
        }
        .onAppear {
            loadSavedData()
        }
    }

    private func saveData(_ gender: Gender) {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        viewModel.saveGender(gender)
    }

    private func loadSavedData() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        if let userInfo = viewModel.loadUserInfo() {
            selectedGender = userInfo.gender
        }
    }
}

#Preview {
    NavigationStack {
        GenderView()
    }
}
