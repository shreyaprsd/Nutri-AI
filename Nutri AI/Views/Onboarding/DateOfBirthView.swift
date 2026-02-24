//
//  DateOfBirthView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/01/26.
// 4 onboarding screen

import SwiftData
import SwiftUI

struct DateOfBirthView: View {
    @State private var selectedMonth = 7
    @State private var selectedDay = 3
    @State private var selectedYear = 2003
    @State private var showAgeAlert = false
    @State private var navigateToNextScreen = false
    @Environment(\.modelContext) private var modelContext
    @State private var userInfoViewModel: UserInfoViewModel?
    @ObservedObject var authViewModel: AuthViewModel

    let currentOnboardingStep: Int
    let totalOnboardingSteps: Int

    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }
        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    init(authViewModel: AuthViewModel, currentOnboardingStep: Int = 4, totalOnboardingSteps: Int = 12) {
        self.authViewModel = authViewModel
        self.currentOnboardingStep = currentOnboardingStep
        self.totalOnboardingSteps = totalOnboardingSteps
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("When were you born?")
                .font(.system(size: 32, weight: .semibold))
            Text("This will be used to calibrate your custom plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }

        Spacer()

        DateOfBirthPickerView(
            selectedMonth: $selectedMonth,
            selectedDay: $selectedDay,
            selectedYear: $selectedYear
        )

        Spacer()

        Button {
            validateAgeAndContinue()
        } label: {
            Text("Continue")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 310, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                )
        }
        .alert("We're sorry!", isPresented: $showAgeAlert) {
            Button("OK") {
                // Just dismiss the alert
            }
        } message: {
            Text("You must be at least 13 years old to use Nutri AI.")
        }
        .navigationDestination(isPresented: $navigateToNextScreen) {
            DesiredGoalView(authViewModel: authViewModel)
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

    private func validateAgeAndContinue() {
        let age = calculateAge()

        if age < 13 {
            showAgeAlert = true
        } else {
            saveData()
            navigateToNextScreen = true
        }
    }

    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let today = Date()

        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDay

        guard let birthDate = calendar.date(from: dateComponents) else {
            return 0
        }

        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: today)
        return ageComponents.year ?? 0
    }

    private func saveData() {
        let calender = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDay

        if let birthDate = calender.date(from: dateComponents) {
            viewModel.saveDateOfBirth(birthDate)

            let age = calculateAge()
            viewModel.saveAge(age)
        }
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo(),
           let savedDate = userInfo.dob
        {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: savedDate)

            if let year = components.year,
               let month = components.month,
               let day = components.day
            {
                selectedYear = year
                selectedMonth = month
                selectedDay = day
            }
        }
    }
}
