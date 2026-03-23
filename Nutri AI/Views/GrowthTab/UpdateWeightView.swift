//
//  UpdateWeightView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 23/02/26.
//

import SwiftData
import SwiftUI

struct UpdateWeightView: View {
    enum Mode {
        case goalWeight
        case currentWeight
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    @State private var isMetric = true
    @State private var weight: Double = 54.0
    @State private var userInfoViewModel: UserInfoViewModel?
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility

    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }

        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            unitToggle

            WeightSelectorView(
                weight: displayWeightBinding,
                minWeight: isMetric ? 30.0 : 66.0,
                maxWeight: isMetric ? 200.0 : 440.0,
                step: isMetric ? 0.5 : 1.0
            )

            Spacer()

            Button {
                saveData()
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                    )
            }
            .padding(.bottom, 16)
        }
        .navigationTitle(Text(navigationTitle))
        .onAppear {
            floatingButtonVisibility.isHidden = true
            loadSavedData()
        }
        .onDisappear {
            floatingButtonVisibility.isHidden = false
        }
    }

    private var unitToggle: some View {
        HStack {
            Text("Imperial")
                .foregroundStyle(isMetric ? .secondary : .primary)
                .padding(.trailing, 40)

            Toggle("", isOn: $isMetric)
                .tint(Color.black)
                .labelsHidden()

            Text("Metric")
                .foregroundStyle(isMetric ? .secondary : .primary)
                .padding(.leading, 40)
        }
        .font(.system(size: 16, weight: .bold))
        .frame(maxWidth: .infinity)
    }

    private var displayWeightBinding: Binding<Double> {
        Binding(
            get: {
                let value = isMetric ? weight : (weight * 2.20462)
                return roundedToSingleDecimal(value)
            },
            set: { newValue in
                let minValue = isMetric ? 30.0 : 66.0
                let maxValue = isMetric ? 200.0 : 440.0
                let bounded = min(max(newValue, minValue), maxValue)
                let rounded = roundedToSingleDecimal(bounded)
                weight = isMetric ? rounded : (rounded / 2.20462)
            }
        )
    }

    private func roundedToSingleDecimal(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }

    private var navigationTitle: String {
        switch mode {
        case .goalWeight:
            "Goal Weight"
        case .currentWeight:
            "Current Weight"
        }
    }

    private func saveData() {
        switch mode {
        case .goalWeight:
            viewModel.saveDesiredWeightAndGoal(weight)
        case .currentWeight:
            viewModel.saveCurrentWeight(weight)
        }
        viewModel.calculateAndSaveNutrition()
    }

    private func loadSavedData() {
        guard let userInfo = viewModel.loadUserInfo() else { return }

        switch mode {
        case .goalWeight:
            if userInfo.desiredWeightInKg > 0 {
                weight = userInfo.desiredWeightInKg
            }
        case .currentWeight:
            if userInfo.weightInKg > 0 {
                weight = userInfo.weightInKg
            }
        }
    }
}

#Preview {
    UpdateWeightView(mode: .currentWeight)
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
