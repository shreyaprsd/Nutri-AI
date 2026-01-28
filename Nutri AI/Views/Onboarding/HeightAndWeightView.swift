//
//  HeightAndWeightView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/01/26.
// 3 onboarding screen

import SwiftData
import SwiftUI

struct HeightWeightView: View {
    @State private var isMetric = true
    @State private var heightInCm: Double = 168
    @State private var weightInKg: Double = 54
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var authViewModel: AuthViewModel

    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    let metricHeights = Array(60 ... 243).map { "\($0) cm" }
    let metricWeights = Array(20 ... 360).map { "\($0) kg" }
    let imperialWeights = Array(50 ... 700).map { "\($0) lb" }

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 3, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            titleSection

            Spacer()

            unitToggle

            pickerSection

            Spacer()

            continueButton
        }
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

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Height & Weight")
                .font(.system(size: 32, weight: .semibold))
            Text("This will be used to calibrate your custom plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
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

            Text("Metrics")
                .foregroundStyle(isMetric ? .secondary : .primary)
                .padding(.leading, 40)
        }
        .font(.system(size: 16, weight: .bold))
        .frame(maxWidth: .infinity)
    }

    private var pickerSection: some View {
        HStack(spacing: 45) {
            if isMetric {
                metricHeightPicker
                metricWeightPicker
            } else {
                imperialHeightPicker
                imperialWeightPicker
            }
        }
    }

    private var metricHeightPicker: some View {
        VStack {
            Text("Height")
                .font(.system(size: 14, weight: .medium))

            Picker("Height", selection: Binding(
                get: { "\(Int(heightInCm)) cm" },
                set: { newValue in
                    if let value = Int(newValue.replacingOccurrences(of: " cm", with: "")) {
                        heightInCm = Double(value)
                    }
                }
            )) {
                ForEach(metricHeights, id: \.self) { height in
                    Text(height).tag(height)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 120, height: 150)
        }
        .padding()
    }

    private var metricWeightPicker: some View {
        VStack {
            Text("Weight")
                .font(.system(size: 14, weight: .medium))

            Picker("Weight", selection: Binding(
                get: { "\(Int(weightInKg)) kg" },
                set: { newValue in
                    if let value = Int(newValue.replacingOccurrences(of: " kg", with: "")) {
                        weightInKg = Double(value)
                    }
                }
            )) {
                ForEach(metricWeights, id: \.self) { weight in
                    Text(weight).tag(weight)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 120, height: 150)
        }
        .padding()
    }

    private var imperialHeightPicker: some View {
        VStack {
            Text("Height")
                .font(.system(size: 14, weight: .medium))

            HStack(spacing: 0) {
                Picker("Feet", selection: createFeetBinding()) {
                    ForEach(2 ... 8, id: \.self) { feet in
                        Text("\(feet) ft").tag(feet)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)

                Picker("Inches", selection: createInchesBinding()) {
                    ForEach(0 ... 11, id: \.self) { inches in
                        Text("\(inches) in").tag(inches)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)
            }
        }
        .padding()
    }

    private var imperialWeightPicker: some View {
        VStack {
            Text("Weight")
                .font(.system(size: 14, weight: .medium))

            Picker("Weight", selection: createImperialWeightBinding()) {
                ForEach(imperialWeights, id: \.self) { weight in
                    Text(weight).tag(weight)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 120, height: 150)
        }
        .padding()
    }

    private func createFeetBinding() -> Binding<Int> {
        Binding(
            get: {
                let totalInches = heightInCm / 2.54
                return Int(totalInches / 12)
            },
            set: { newFeet in
                let currentInches = Int((heightInCm / 2.54).truncatingRemainder(dividingBy: 12))
                let totalInches = Double(newFeet * 12 + currentInches)
                heightInCm = totalInches * 2.54
            }
        )
    }

    private func createInchesBinding() -> Binding<Int> {
        Binding(
            get: {
                let totalInches = heightInCm / 2.54
                return Int(totalInches.truncatingRemainder(dividingBy: 12))
            },
            set: { newInches in
                let currentFeet = Int(heightInCm / 2.54 / 12)
                let totalInches = Double(currentFeet * 12 + newInches)
                heightInCm = totalInches * 2.54
            }
        )
    }

    private func createImperialWeightBinding() -> Binding<String> {
        Binding(
            get: {
                let pounds = weightInKg * 2.20462
                return "\(Int(pounds)) lb"
            },
            set: { newValue in
                if let value = Int(newValue.replacingOccurrences(of: " lb", with: "")) {
                    weightInKg = Double(value) / 2.20462
                }
            }
        )
    }

    private var continueButton: some View {
        NavigationLink(destination: DateOfBirthView(authViewModel: authViewModel)) {
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
            saveData()
        })
    }

    private func saveData() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        viewModel.saveHeightAndWeight(height: heightInCm, weight: weightInKg)
    }

    private func loadSavedData() {
        let viewModel = UserInfoViewModel(modelContext: modelContext)
        if let userInfo = viewModel.loadUserInfo() {
            if userInfo.heightInCm > 0 {
                heightInCm = userInfo.heightInCm
            }
            if userInfo.weightInKg > 0 {
                weightInKg = userInfo.weightInKg
            }
        }
    }
}
