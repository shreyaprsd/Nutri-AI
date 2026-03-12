//
//  BMI.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/03/26.
//

import Foundation
import SwiftUI

enum BMIValue: String {
    case underweight = "Underweight"
    case normal = "Normal"
    case overweight = "Overweight"
    case obese = "Obese"

    init(bmi: Double) {
        switch bmi {
        case ..<18.5: self = .underweight
        case 18.5 ..< 25: self = .normal
        case 25 ..< 30: self = .overweight
        default: self = .obese
        }
    }

    var color: Color {
        switch self {
        case .underweight: .blue
        case .normal: .green
        case .overweight: .yellow
        case .obese: .red
        }
    }
}
