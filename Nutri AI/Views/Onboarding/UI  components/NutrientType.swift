//
//  NutrientType.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 26/01/26.
//

import Foundation
import SwiftUI

enum NutrientType {
    case calories
    case carbs
    case protein
    case fats

    var displayName: String {
        switch self {
        case .calories: "Calories"
        case .carbs: "Carbs"
        case .protein: "Protein"
        case .fats: "Fats"
        }
    }

    var unit: String {
        switch self {
        case .calories: ""
        case .carbs, .protein, .fats: "g"
        }
    }

    var icon: String {
        switch self {
        case .calories: "🔥"
        case .carbs: "🌾"
        case .protein: "🍗"
        case .fats: "🥑"
        }
    }

    var ringColor: Color {
        switch self {
        case .calories: .black
        case .carbs: Color(red: 0.85, green: 0.6, blue: 0.4)
        case .protein: Color(red: 46 / 255, green: 204 / 255, blue: 113 / 255)
        case .fats: Color(red: 52 / 255, green: 120 / 255, blue: 246 / 255)
        }
    }
}
