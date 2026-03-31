import SwiftUI

struct GenderSelectionView: View {
    @Binding var selectedGender: Gender?
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Gender.allCases, id: \.self) { gender in
                Button {
                    selectedGender = gender
                } label: {
                    Text(gender.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedGender == gender ? theme.buttonForeground : .primary)
                        .frame(width: 310, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGender == gender ? theme.buttonBackground : Color(.systemGray6))
                        )
                }
            }
        }
    }
}

#Preview {
    GenderSelectionView(selectedGender: .constant(.female))
}
