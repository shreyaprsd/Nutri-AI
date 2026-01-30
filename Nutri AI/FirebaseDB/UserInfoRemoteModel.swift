//
//  UserInfoRemoteModel.swift
//  Nutri AI
//

import FirebaseFirestore
import Foundation

struct UserInfoRemoteModel: Codable {
    @DocumentID var id: String?
    var gender: String?
    var workoutFrequency: String?
    var age: Int
    var heightInCm: Double
    var weightInKg: Double
    var dateOfBirth: Timestamp?
    var desiredGoal: String?
    var desiredWeightInKg: Double
    var calculations: CalculationsRemote?

    struct CalculationsRemote: Codable {
        var bmr: Int
        var tdee: Int
        var targetDailyCalories: Double
        var macros: MacrosRemote
    }

    struct MacrosRemote: Codable {
        var protein: Double
        var carbs: Double
        var fats: Double
    }

    init(from model: UserInfoModel) {
        gender = model.gender?.rawValue
        workoutFrequency = model.workoutFrequency?.rawValue
        age = model.age
        heightInCm = model.heightInCm
        weightInKg = model.weightInKg
        if let dob = model.dob {
            dateOfBirth = Timestamp(date: dob)
        }
        desiredGoal = model.desiredGoal?.rawValue
        desiredWeightInKg = model.desiredWeightInKg

        if let calc = model.calculations {
            calculations = CalculationsRemote(
                bmr: calc.bmr,
                tdee: calc.tdee,
                targetDailyCalories: calc.targetDailyCalories,
                macros: MacrosRemote(
                    protein: calc.macros.protein,
                    carbs: calc.macros.carbs,
                    fats: calc.macros.fats
                )
            )
        }
    }

    func toUserInfoModel(_ model: UserInfoModel) {
        if let g = gender { model.gender = Gender(rawValue: g) }
        if let w = workoutFrequency { model.workoutFrequency = WorkoutFrequency(rawValue: w) }
        model.age = age
        model.heightInCm = heightInCm
        model.weightInKg = weightInKg
        if let dob = dateOfBirth {
            model.dob = dob.dateValue()
        }
        if let g = desiredGoal { model.desiredGoal = Goal(rawValue: g) }
        model.desiredWeightInKg = desiredWeightInKg

        if let calc = calculations {
            model.calculations = Calculations(
                bmr: calc.bmr,
                tdee: calc.tdee,
                targetDailyCalories: calc.targetDailyCalories,
                macros: Macros(
                    protein: calc.macros.protein,
                    carbs: calc.macros.carbs,
                    fats: calc.macros.fats
                )
            )
        }
    }
}
