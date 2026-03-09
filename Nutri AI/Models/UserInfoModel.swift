//
//  UserInfoModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/01/26.
//

import Foundation
import SwiftData

@Model
final class UserInfoModel {
    @Attribute(.unique) var id = UUID()
    var gender: Gender?
    var workoutFrequency: WorkoutFrequency?
    var age: Int = 0
    var heightInCm: Double = 0.0
    var weightInKg: Double = 0.0
    var dob: Date?
    var desiredGoal: Goal?
    var desiredWeightInKg: Double = 0.0
    var calculations: Calculations?
    init(gender: Gender? = nil) {
        self.gender = gender
    }
}

struct Calculations: Codable {
    var bmr: Int
    var tdee: Int
    var targetDailyCalories: Double
    var macros: Macros
}

struct Macros: Codable {
    var protein: Double
    var carbs: Double
    var fats: Double
}
