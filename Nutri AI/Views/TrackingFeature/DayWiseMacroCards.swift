//
//  DayWiseMacroCards.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 14/02/26.
//

import SwiftData
import SwiftUI

struct DayWiseCalorieCard: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries:
        [NutritionModel]
    @Binding var selectedDate: Date
    @Query private var users: [UserInfoModel]
    @Environment(\.modelContext) private var modelContext
    let nutrientType: NutrientType
    let ringColor: Color
    let nutrientIcon: String
    let cardHeight: CGFloat
    let cardWidth: CGFloat
    private var filteredEntries: [NutritionModel] {
        let calendar = Calendar.current
        return foodEntries.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }

    private var totalIntake: Double {
        filteredEntries.reduce(0) { total, entry in
            total + intakeNutrientValue(for: nutrientType, in: entry)
        }
    }

    private func intakeNutrientValue(
        for nutrientType: NutrientType,
        in entry: NutritionModel
    ) -> Double {
        switch nutrientType {
        case .calories:
            return Double(entry.nutrients.calories) ?? 0
        case .carbs:
            return entry.nutrients.carbs.total
        case .protein:
            return entry.nutrients.protein.total
        case .fats:
            return entry.nutrients.fats.total
        }
    }

    private var targetIntake: Double {
        guard let user = users.first else { return 0 }
        let calculations =
            user.calculations
            ?? NutritionCalculation.calculateAll(userInfo: user)
        return targetValue(for: nutrientType, calculations: calculations)
    }

    private func targetValue(
        for nutrientType: NutrientType,
        calculations: Calculations?
    ) -> Double {
        guard let calculations else { return 0 }
        switch nutrientType {
        case .calories:
            return calculations.targetDailyCalories
        case .carbs:
            return calculations.macros.carbs
        case .protein:
            return calculations.macros.protein
        case .fats:
            return calculations.macros.fats
        }
    }

    private var nutrientValueLeft: Double {
        totalIntake - targetIntake
    }

    private var progress: Double {
        guard targetIntake > 0 else { return 0 }
        return min(totalIntake / targetIntake, 1)
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
                                intake: progress,
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
                                Int(abs(nutrientValueLeft).rounded()),
                                format: .number.grouping(.never)
                            )
                            .font(Font.system(size: 36, weight: .medium))
                            Text(
                                totalIntake > targetIntake
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
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries:
        [NutritionModel]
    @Binding var selectedDate: Date
    @Query private var users: [UserInfoModel]
    @Environment(\.modelContext) private var modelContext
    let nutrientType: NutrientType
    let ringColor: Color
    let nutrientIcon: String
    let cardHeight: CGFloat
    let cardWidth: CGFloat
    private var filteredEntries: [NutritionModel] {
        let calendar = Calendar.current
        return foodEntries.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }
    private var totalIntake: Double {
        filteredEntries.reduce(0) { total, entry in
            total + intakeNutrientValue(for: nutrientType, in: entry)
        }
    }

    private func intakeNutrientValue(
        for nutrientType: NutrientType,
        in entry: NutritionModel
    ) -> Double {
        switch nutrientType {
        case .calories:
            return Double(entry.nutrients.calories) ?? 0
        case .carbs:
            return entry.nutrients.carbs.total
        case .protein:
            return entry.nutrients.protein.total
        case .fats:
            return entry.nutrients.fats.total
        }
    }

    private var targetIntake: Double {
        guard let user = users.first else { return 0 }
        let calculations =
            user.calculations
            ?? NutritionCalculation.calculateAll(userInfo: user)
        return targetValue(for: nutrientType, calculations: calculations)
    }

    private func targetValue(
        for nutrientType: NutrientType,
        calculations: Calculations?
    ) -> Double {
        guard let calculations else { return 0 }
        switch nutrientType {
        case .calories:
            return calculations.targetDailyCalories
        case .carbs:
            return calculations.macros.carbs
        case .protein:
            return calculations.macros.protein
        case .fats:
            return calculations.macros.fats
        }
    }

    private var nutrientValueLeft: Double {
        totalIntake - targetIntake
    }

    private var progress: Double {
        guard targetIntake > 0 else { return 0 }
        return min(totalIntake / targetIntake, 1)
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
                            ZStack {
                                DynamicProgressRing(
                                    intake: progress,
                                    ringColor: ringColor
                                )
                                .frame(width: 60, height: 60)
                                Text(nutrientIcon)
                                    .font(.system(size: 18))
                                    .frame(width: 26, height: 26)
                                    .minimumScaleFactor(0.8)
                            }
                            Text(
                                Int(abs(nutrientValueLeft).rounded()),
                                format: .number.grouping(.never)
                            )
                            .font(Font.system(size: 20, weight: .medium))
                            Text(
                                totalIntake > targetIntake
                                    ? "\(nutrientType.displayName) eaten "
                                    : "\(nutrientType.displayName) left "
                            )
                            .font(Font.system(size: 16, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
            }
        }
    }
}

struct DynamicProgressRing: View {
    let intake: Double
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color

    init(
        intake: Double,
        lineWidth: CGFloat = 8,
        ringColor: Color = .blue,
        backgroundColor: Color = .gray.opacity(0.2)
    ) {
        self.intake = intake
        self.lineWidth = lineWidth
        self.ringColor = ringColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: intake)
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
