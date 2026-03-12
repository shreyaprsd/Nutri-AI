//
//  Extension.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0

        Scanner(string: cleanHexCode).scanHexInt64(&rgb)

        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0

        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

// round off the decimal to whole number
extension Double {
    func cleanString() -> String {
        let rounded = rounded()
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .decimal

        return formatter.string(from: NSNumber(value: rounded)) ?? "\(Int(rounded))"
    }

    // Rounds the double to specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension [NutritionModel] {
    func entries(for date: Date) -> [NutritionModel] {
        let calendar = Calendar.current
        return filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }
}

extension Double {
    func formattedWeight(unit: String = "kg") -> String? {
        self > 0 ? String(format: "%.1f \(unit)", self) : nil
    }

    func formattedHeight(unit: String = "cm") -> String? {
        self > 0 ? String(format: "%.0f \(unit)", self) : nil
    }
}
