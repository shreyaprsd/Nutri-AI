//
//  DayWiseMacroCards.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/02/26.
//

import SwiftUI

struct DayWiseCalorieCard: View {
    @EnvironmentObject private var cardsStore: MacroCardsStore
    let nutrientType: NutrientType
    let ringColor: Color
    let nutrientIcon: String
    let cardHeight: CGFloat
    let cardWidth: CGFloat

    private var cardsData: MacroCardsData {
        cardsStore.data(for: nutrientType)
    }

    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                    .fill(Color.white)
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(alignment: .trailing) {
                        ZStack {
                            DynamicProgressRing(
                                intake: cardsData.progress,
                                ringColor: ringColor
                            )
                            .frame(width: 90, height: 90)
                            Text(nutrientIcon)
                                .font(.system(size: 20))
                                .frame(width: 28, height: 28)
                                .minimumScaleFactor(0.8)
                        }
                        .padding()
                    }
                    .overlay(alignment: .leading) {
                        VStack(spacing: 4) {
                            Text(
                                Int(abs(cardsData.remaining).rounded()),
                                format: .number.grouping(.never)
                            )
                            .font(Font.system(size: 36, weight: .medium))
                            Text(
                                cardsData.totalIntake > cardsData.targetIntake
                                    ? "\(nutrientType.displayName) eaten "
                                    : "\(nutrientType.displayName) left "
                            )
                            .font(Font.system(size: 12, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        }
                        .padding()
                    }
            }
        }
        .padding()
    }
}

struct DayWiseMacroCards: View {
    @EnvironmentObject private var cardsStore: MacroCardsStore
    let nutrientType: NutrientType
    let ringColor: Color
    let nutrientIcon: String
    let cardHeight: CGFloat
    let cardWidth: CGFloat

    private var cardsData: MacroCardsData {
        cardsStore.data(for: nutrientType)
    }

    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                    .fill(Color.white)
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(alignment: .center) {
                        VStack(spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text(
                                    Int(abs(cardsData.remaining).rounded()),
                                    format: .number.grouping(.never)
                                )
                                Text(nutrientType.unit)
                            }
                            .font(Font.system(size: 20, weight: .medium))
                            Text(
                                cardsData.totalIntake > cardsData.targetIntake
                                    ? "\(nutrientType.displayName) eaten "
                                    : "\(nutrientType.displayName) left "
                            )
                            .font(Font.system(size: 12, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)

                            ZStack {
                                DynamicProgressRing(
                                    intake: cardsData.progress,
                                    ringColor: ringColor
                                )
                                .frame(width: 60, height: 60)
                                Text(nutrientIcon)
                                    .font(.system(size: 18))
                                    .frame(width: 26, height: 26)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
            }
        }
    }
}
