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
    var gender: Gender?
    var workoutFrequency: WorkoutFrequency?
    var heightInCm: Double = 0.0
    var weightInKg: Double = 0.0
    var dob: Date?
    var desiredGoal: Goal?
    var desiredWeightInKg: Double = 0.0

    init(gender: Gender? = nil) {
        self.gender = gender
    }
}
