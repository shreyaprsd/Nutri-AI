import SwiftData
import SwiftUI

struct UpdateDateOfBirthView: View {
    @State private var selectedMonth = 7
    @State private var selectedDay = 23
    @State private var selectedYear = 2003
    @State private var validationMessage: String?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var userInfoViewModel: UserInfoViewModel?
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility
    @Environment(\.appTheme) private var theme

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

            DateOfBirthPickerView(
                selectedMonth: $selectedMonth,
                selectedDay: $selectedDay,
                selectedYear: $selectedYear
            )

            Spacer()

            Button {
                validateAndSave()
            } label: {
                Text("Save")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.buttonForeground)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.buttonBackground)
                    )
            }
            .alert("Invalid date of birth", isPresented: .constant(validationMessage != nil)) {
                Button("OK", role: .cancel) { validationMessage = nil }
            } message: {
                Text(validationMessage ?? "")
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("Date of Birth")
        .onAppear {
            floatingButtonVisibility.isHidden = true
            loadSavedData()
        }
        .onDisappear {
            floatingButtonVisibility.isHidden = false
        }
    }

    private var birthDate: Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDay
        return calendar.date(from: dateComponents)
    }

    private func calculateAge(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: today)
        return ageComponents.year ?? 0
    }

    private func validateAndSave() {
        guard let birthDate else {
            validationMessage = "Please select a valid date."
            return
        }

        let age = calculateAge(from: birthDate)
        guard age >= 13 else {
            validationMessage = "You must be at least 13 years old to use Nutri AI."
            return
        }

        viewModel.saveDateOfBirth(birthDate)
        viewModel.saveAge(age)
        viewModel.calculateAndSaveNutrition()
        dismiss()
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

#Preview {
    UpdateDateOfBirthView()
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
