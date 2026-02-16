//
//  MacroCardsData.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 16/02/26.
//

internal import Combine
import SwiftUI

final class MacroCardsStore: ObservableObject {
    @Published var foodEntries: [NutritionModel] = []
    @Published var users: [UserInfoModel] = []
    @Published var selectedDate: Date = .init()

    func data(for nutrientType: NutrientType) -> MacroCardsData {
        MacroCardsData(
            foodEntries: foodEntries,
            users: users,
            nutrientType: nutrientType,
            selectedDate: selectedDate
        )
    }
}

struct MacroCardsData {
    let foodEntries: [NutritionModel]
    let users: [UserInfoModel]
    let nutrientType: NutrientType
    let selectedDate: Date

    var filteredEntries: [NutritionModel] {
        foodEntries.entries(for: selectedDate)
    }

    var totalIntake: Double {
        filteredEntries.reduce(0) { $0 + intakeValue(for: $1) }
    }

    var targetIntake: Double {
        guard let user = users.first,
              let calculations = user.calculations ?? NutritionCalculation.calculateAll(userInfo: user)
        else {
            return 0
        }
        return targetValue(calculations: calculations)
    }

    var progress: Double {
        guard targetIntake > 0 else { return 0 }
        return min(totalIntake / targetIntake, 1)
    }

    var remaining: Double { totalIntake - targetIntake }

    func intakeValue(for entry: NutritionModel) -> Double {
        let multiplier = entry.servingMultiplier
        switch nutrientType {
        case .calories:
            return (Double(entry.nutrients.calories) ?? 0) * multiplier
        case .carbs:
            return entry.nutrients.carbs.total * multiplier
        case .protein:
            return entry.nutrients.protein.total * multiplier
        case .fats:
            return entry.nutrients.fats.total * multiplier
        }
    }

    func targetValue(calculations: Calculations) -> Double {
        switch nutrientType {
        case .calories:
            calculations.targetDailyCalories
        case .carbs:
            calculations.macros.carbs
        case .protein:
            calculations.macros.protein
        case .fats:
            calculations.macros.fats
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
