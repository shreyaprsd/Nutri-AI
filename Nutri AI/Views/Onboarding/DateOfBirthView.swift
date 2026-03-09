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

    let months = [
        (1, "January"), (2, "February"), (3, "March"), (4, "April"),
        (5, "May"), (6, "June"), (7, "July"), (8, "August"),
        (9, "September"), (10, "October"), (11, "November"), (12, "December"),
    ]

    let years = Array(1930 ... 2030)

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

        HStack {
            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.0) { month in
                    Text(month.1).tag(month.0)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: selectedMonth) { _, _ in
                adjustDayIfNeeded()
            }

            Picker("Day", selection: $selectedDay) {
                ForEach(availableDays, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.wheel)

            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(verbatim: "\(year)").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: selectedYear) { _, _ in
                adjustDayIfNeeded()
            }
        }
        .padding()

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

    private var availableDays: [Int] {
        let maxDay = daysInMonth(month: selectedMonth, year: selectedYear)
        return Array(1 ... maxDay)
    }

    private func daysInMonth(month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            31
        case 4, 6, 9, 11:
            30
        case 2:
            isLeapYear(year: year) ? 29 : 28
        default:
            31
        }
    }

    private func isLeapYear(year: Int) -> Bool {
        if year % 400 == 0 {
            return true
        }
        if year % 100 == 0 {
            return false
        }
        if year % 4 == 0 {
            return true
        }
        return false
    }

    private func adjustDayIfNeeded() {
        let maxDay = daysInMonth(month: selectedMonth, year: selectedYear)
        if selectedDay > maxDay {
            selectedDay = maxDay
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
