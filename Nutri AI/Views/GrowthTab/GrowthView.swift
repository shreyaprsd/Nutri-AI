//
//  GrowthView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import Foundation
import SwiftData
import SwiftUI

struct GrowthView: View {
    @Query private var users: [UserInfoModel]
    @State private var userInfoViewModel: UserInfoViewModel?
    @State private var desiredWeight: Double?
    @State private var currentWeight: Double?
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility
    @Environment(\.modelContext) private var modelContext
    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }
        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                weightGoalView
                    .padding(.top, 28)
                    .padding(.bottom, 20)
                currentWeightView
                    .padding(.bottom, 20)
                BMIView()
                    .padding(.bottom, 20)
                GrowthBarGraphView()
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(Text("Progress"))
        .onAppear {
            loadSavedData()
            floatingButtonVisibility.isHidden = true
        }
    }

    private var weightGoalView: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color.yellow)
                Image(systemName: "trophy")
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.white)
                Image(systemName: "trophy.fill")
            }
            Text("Goal Weight: \(goalWeightText)")
                .font(.system(size: 14, weight: .regular))
            Spacer()
            NavigationLink {
                UpdateWeightView(mode: .goalWeight)
            } label: {
                Text("Update")
                    .frame(width: 64, height: 20)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.black)
            .foregroundStyle(Color.white)
            .frame(width: 64, height: 20)
            .padding(.trailing, 15)
        }
        .frame(width: 320)
    }

    private var goalWeightText: String {
        (desiredWeight ?? users.first?.desiredWeightInKg ?? viewModel.loadUserInfo()?.desiredWeightInKg)
            .flatMap { $0 > 0 ? String(format: "%.1f kg", $0) : nil }
            ?? "Not set"
    }

    private var currentWeightView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 320, height: 136)
                .foregroundStyle(Color.white)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 36, height: 36)
                                    .foregroundStyle(Color.black)
                                Image(systemName: "dumbbell.fill")
                                    .foregroundStyle(Color.white)
                            }
                            Text("Current Weight: \(currentWeightText)")
                                .font(.system(size: 14, weight: .regular))
                        }
                        .padding(.bottom, 8)
                        Spacer()
                        Text("""
                        Remember to update this atleast once a week so we can adjust your plan to hit your goal
                        """)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        NavigationLink {
                            UpdateWeightView(mode: .currentWeight)
                        } label: {
                            Text("Update your weight")
                                .frame(maxWidth: 320)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.black)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 8)
                    }
                    .padding()
                }
        }
    }

    private var currentWeightText: String {
        (currentWeight ?? users.first?.weightInKg ?? viewModel.loadUserInfo()?.weightInKg)
            .flatMap { $0 > 0 ? String(format: "%.1f kg", $0) : nil }
            ?? "Not set"
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            if userInfo.desiredWeightInKg > 0 {
                desiredWeight = userInfo.desiredWeightInKg
            }
            if userInfo.weightInKg > 0 {
                currentWeight = userInfo.weightInKg
            }
        }
    }
}

#Preview {
    NavigationStack {
        GrowthView()
    }
}
