//
//  NutritionCalculation.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/01/26.
//

import Foundation

class NutritionCalculation {
    private enum ActivityMultiplier: Double {
        case light = 1.375
        case moderate = 1.55
        case heavy = 1.725 
    }

    private enum ProteinMultiplier: Double {
        case weightLoss = 2.2
        case maintain = 1.6
        case weightGain = 1.8
    }

    static func calculateBMR(gender: Gender, weightInKg: Double, heightInCm: Double, age: Int) -> Int {
        let baseBMR = (10 * weightInKg) + (6.25 * heightInCm) - (5 * Double(age))

        let bmr: Double = switch gender {
        case .male:
            baseBMR + 5
        case .female:
            baseBMR - 161
        case .other:
            baseBMR - 78
        }
        return Int(bmr.rounded())
    }

    static func calculateTDEE(bmr: Int, workoutFrequency: WorkoutFrequency) -> Int {
        let multiplier: ActivityMultiplier = switch workoutFrequency {
        case .light:
            .light
        case .moderate:
            .moderate
        case .heavy:
            .heavy
        }

        let tdee = Double(bmr) * multiplier.rawValue
        return Int(tdee.rounded())
    }

    static func calculateTargetCalories(tdee: Int, goal: Goal) -> Double {
        switch goal {
        case .weightLoss:
            Double(tdee - 500)
        case .maintain:
            Double(tdee)
        case .weightGain:
            Double(tdee + 250)
        }
    }


    static func calculateMacros(targetCalories: Double, weightInKg: Double, goal: Goal) -> Macros {
   
        let proteinMultiplier: ProteinMultiplier = switch goal {
        case .weightLoss:
            .weightLoss
        case .maintain:
            .maintain
        case .weightGain:
            .weightGain
        }

        let proteinGrams = weightInKg * proteinMultiplier.rawValue
        let proteinCalories = proteinGrams * 4

        let fatCalories = targetCalories * 0.25
        let fatGrams = fatCalories / 9

        let remainingCalories = targetCalories - proteinCalories - fatCalories
        let carbGrams = remainingCalories / 4
        return Macros(
            protein: proteinGrams.rounded(toPlaces: 1),
            carbs: carbGrams.rounded(toPlaces: 1),
            fats: fatGrams.rounded(toPlaces: 1)
        )
    }


    static func calculateAll(userInfo: UserInfoModel) -> Calculations? {

        guard let gender = userInfo.gender,
              let workoutFrequency = userInfo.workoutFrequency,
              let goal = userInfo.desiredGoal,
              userInfo.age > 0,
              userInfo.heightInCm > 0,
              userInfo.weightInKg > 0
        else {
            return nil
        }

        let bmr = calculateBMR(
            gender: gender,
            weightInKg: userInfo.weightInKg,
            heightInCm: userInfo.heightInCm,
            age: userInfo.age
        )


        let tdee = calculateTDEE(
            bmr: bmr,
            workoutFrequency: workoutFrequency
        )

        let targetCalories = calculateTargetCalories(
            tdee: tdee,
            goal: goal
        )

        let macros = calculateMacros(
            targetCalories: targetCalories,
            weightInKg: userInfo.weightInKg,
            goal: goal
        )

        return Calculations(
            bmr: bmr,
            tdee: tdee,
            targetDailyCalories: targetCalories.rounded(toPlaces: 1),
            macros: macros
        )
    }
}
