//
//  NutrientCardView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 26/01/26.
//

import SwiftUI

struct NutritionCard: View {
    let nutrientType: NutrientType
    @Binding var nutrientValue: Double

    @Environment(\.appTheme) private var theme

    var body: some View {
        NavigationLink(
            destination: EditNutrientView(
                currentValue: $nutrientValue, nutrientType: nutrientType,
                ringColor: nutrientType.ringColor,
                nutrientIcon: nutrientType.icon
            )
        ) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.border, lineWidth: 2)
                    .fill(theme.cardBackground)
                    .frame(width: 150, height: 150)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20))
                            .padding(8)
                    }

                VStack {
                    Text(nutrientType.displayName)
                        .font(Font.system(size: 24, weight: .regular))

                    ZStack {
                        CircularProgressRing(
                            progress: 0.5,
                            lineWidth: 4,
                            ringColor: nutrientType.ringColor,
                            backgroundColor: .gray.opacity(0.1)
                        )
                        .frame(width: 84, height: 84)
                        .padding(.bottom, 8)

                        Text(nutrientValue.cleanString() + nutrientType.unit)
                            .font(.system(size: 20, weight: .regular))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
