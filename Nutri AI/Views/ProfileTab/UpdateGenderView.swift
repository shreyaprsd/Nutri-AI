import SwiftData
import SwiftUI

struct UpdateGenderView: View {
    @State private var selectedGender: Gender?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
        VStack(spacing: 16) {
            Spacer()

            GenderSelectionView(selectedGender: $selectedGender)

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
            .disabled(selectedGender == nil)
            .opacity(selectedGender == nil ? 0.3 : 1.0)
            .padding(.bottom, 20)
        }
        .navigationTitle("Gender")
        .onAppear {
            floatingButtonVisibility.isHidden = true
            loadSavedData()
        }
        .onDisappear {
            floatingButtonVisibility.isHidden = false
        }
    }

    private func saveData() {
        if let gender = selectedGender {
            viewModel.saveGender(gender)
            viewModel.calculateAndSaveNutrition()
        }
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            selectedGender = userInfo.gender
        }
    }
}

#Preview {
    UpdateGenderView()
        .modelContainer(for: UserInfoModel.self, inMemory: true)
}
