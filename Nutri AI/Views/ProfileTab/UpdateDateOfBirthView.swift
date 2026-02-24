import SwiftData
import SwiftUI

struct UpdateDateOfBirthView: View {
    @State private var selectedMonth = 7
    @State private var selectedDay = 23
    @State private var selectedYear = 2003
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var hideFloatingButton: Bool
    @State private var userInfoViewModel: UserInfoViewModel?

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
        .navigationTitle("Date of Birth")
        .onAppear {
            hideFloatingButton = true
            loadSavedData()
        }
        .onDisappear {
            hideFloatingButton = false
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
            viewModel.saveAge(calculateAge())
            viewModel.calculateAndSaveNutrition()
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

#Preview {
    UpdateDateOfBirthView(hideFloatingButton: .constant(false))
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
