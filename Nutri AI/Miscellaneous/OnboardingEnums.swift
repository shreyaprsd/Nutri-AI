//
//  OnboardingEnums.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/01/26.
//

import Foundation
import SwiftUI

// gender enums
enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

// enums to store workout frquency
enum WorkoutFrequency: String, CaseIterable, Identifiable, Codable {
    case light = "0-2"
    case moderate = "3-5"
    case heavy = "6+"

    var id: String { rawValue }
    var title: String {
        switch self {
        case .light: "0-2"
        case .moderate: "3-5"
        case .heavy: "6+"
        }
    }

    var description: String {
        switch self {
        case .light: "Workouts now and then"
        case .moderate: "A few workouts per week"
        case .heavy: "Dedicated athlete"
        }
    }

    var icon: String {
        switch self {
        case .light: "circle.fill"
        case .moderate: "circle.grid.2x2.fill"
        case .heavy: "square.grid.3x3.fill"
        }
    }
}

// Desired goal enums
enum Goal: String, CaseIterable, Codable {
    case weightLoss = "Weight Loss"
    case maintain = "Maintain Weight"
    case weightGain = "Weight Gain"
}

enum UserDefaultsKey {
    static let hasStartedOnboarding = "hasStartedOnboarding"
}

enum MacroType: String, CaseIterable {
    case protein = "Protein"
    case carbs = "Carbs"
    case fats = "Fats"

    var color: Color {
        switch self {
        case .protein:
            Color(red: 0.88, green: 0.38, blue: 0.38)
        case .carbs:
            Color(red: 0.90, green: 0.68, blue: 0.45)
        case .fats:
            Color(red: 0.45, green: 0.59, blue: 0.86)
        }
    }
}
