import SwiftData
import SwiftUI

struct UpdateHeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var hideFloatingButton: Bool
    @State private var isMetric = true
    @State private var heightInCm: Double = 168
    @State private var existingWeightInKg: Double = 0
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

            unitToggle

            HeightPickerView(heightInCm: $heightInCm, isMetric: $isMetric)

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
        .navigationTitle("Height")
        .onAppear {
            hideFloatingButton = true
            loadSavedData()
        }
        .onDisappear {
            hideFloatingButton = false
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

    private func saveData() {
        viewModel.saveHeightAndWeight(height: heightInCm, weight: existingWeightInKg)
        viewModel.calculateAndSaveNutrition()
    }

    private func loadSavedData() {
        guard let userInfo = viewModel.loadUserInfo() else { return }
        if userInfo.heightInCm > 0 {
            heightInCm = userInfo.heightInCm
        }
        if userInfo.weightInKg > 0 {
            existingWeightInKg = userInfo.weightInKg
        }
    }
}

#Preview {
    UpdateHeightView(hideFloatingButton: .constant(false))
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
