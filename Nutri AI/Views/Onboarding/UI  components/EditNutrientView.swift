//
//  EditNutrientView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 26/01/26.
//

import SwiftData
import SwiftUI

struct EditNutrientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Binding var currentValue: Double
    @State private var inputValue: String = ""
    @State private var originalValue: Double = 0.0
    @FocusState private var isTextFieldFocused: Bool
    let nutrientType: NutrientType
    let ringColor: Color
    let nutrientIcon: String

    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Edit \(nutrientType.displayName) Goal")
                    .font(.system(size: 24, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 46)

            VStack(spacing: 16) {
                currentValueCard
                inputFieldCard
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    inputValue = String(Int(originalValue.rounded()))
                } label: {
                    Text("Revert")
                        .frame(width: 135, height: 42)
                        .foregroundStyle(theme.primaryFill)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.border, lineWidth: 1)
                        )
                }

                Button {
                    if let newValue = Double(inputValue) {
                        currentValue = newValue
                        let viewModel = UserInfoViewModel(modelContext: modelContext)
                        viewModel.updateNutrient(nutrientType: nutrientType, value: newValue)
                    }
                    dismiss()
                } label: {
                    Text("Done")
                        .frame(width: 135, height: 42)
                        .foregroundStyle(theme.primaryFillContent)
                        .background(theme.primaryFill)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            originalValue = currentValue
            inputValue = String(Int(currentValue.rounded()))
            isTextFieldFocused = true
        }
    }

    private var currentValueCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .frame(width: 272, height: 72)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.border, style: StrokeStyle(lineWidth: 1))
                }

            HStack(spacing: 16) {
                ZStack {
                    CircularProgressRing(
                        progress: 0.5,
                        lineWidth: 4,
                        ringColor: ringColor,
                        backgroundColor: Color.gray.opacity(0.1)
                    )
                    .frame(width: 55, height: 55)

                    Text(nutrientIcon)
                        .font(.system(size: 24))
                }

                Text(currentValue.cleanString() + nutrientType.unit)
                    .font(.system(size: 14, weight: .regular))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(width: 272)
        }
    }

    private var inputFieldCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .frame(width: 272, height: 60)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.border, style: StrokeStyle(lineWidth: 1))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(nutrientType.displayName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)

                TextField("", text: $inputValue)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .regular))
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(width: 272, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        EditNutrientView(
            currentValue: .constant(930), nutrientType: .calories,
            ringColor: .black,
            nutrientIcon: "🔥"
        )
    }
}
