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
                    .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                    .fill(Color.white)
                    .frame(width: 150, height: 150)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .padding(8)
                    }

                VStack {
                    Text(nutrientType.displayName)
                        .font(Font.system(size: 24, weight: .regular))
                        .foregroundStyle(.black)

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
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
