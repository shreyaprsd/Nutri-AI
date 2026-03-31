import SwiftData
import SwiftUI

struct UpdateHeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isMetric = true
    @State private var heightInCm: Double = 168
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

            UnitToggleView(isMetric: $isMetric)

            HeightPickerView(heightInCm: $heightInCm, isMetric: $isMetric)

            Spacer()

            Button {
                saveData()
                dismiss()
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
            .padding(.bottom, 16)
        }
        .navigationTitle("Height")
        .onAppear {
            floatingButtonVisibility.isHidden = true
            loadSavedData()
        }
        .onDisappear {
            floatingButtonVisibility.isHidden = false
        }
    }

    private func loadSavedData() {
        guard let userInfo = viewModel.loadUserInfo() else { return }
        if userInfo.heightInCm > 0 {
            heightInCm = userInfo.heightInCm
        }
    }

    private func saveData() {
        viewModel.saveHeight(height: heightInCm)
        viewModel.calculateAndSaveNutrition()
    }
}

#Preview {
    UpdateHeightView()
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
