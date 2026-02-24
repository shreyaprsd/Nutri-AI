//
//  BMIView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 23/02/26.
//

import SwiftData
import SwiftUI

struct BMIView: View {
    @Query private var users: [UserInfoModel]

    private var bmiValue: Double? {
        let userInfo = users.first
        let weight = userInfo?.weightInKg ?? 0
        let height = userInfo?.heightInCm ?? 0

        guard weight > 0, height > 0 else { return nil }
        return NutritionCalculation.calculateBMI(weightInkg: weight, heightInCm: height)
    }

    private var bmiText: String {
        guard let bmiValue else { return "Not set" }
        return String(format: "%.1f", bmiValue)
    }

    private var bmiCategoryText: String {
        guard let bmiValue else { return "" }
        return BMIValue(bmi: bmiValue).rawValue
    }

    private var bmiCategoryColor: Color {
        guard let bmiValue else { return .clear }
        let category = BMIValue(bmi: bmiValue)
        return BMIColor(bmiValue: category).color
    }

    private var bmiNormalizedPosition: CGFloat {
        guard let bmiValue else { return 0.0 }
        // Clamp BMI to a visible range for the slider marker.
        let minBMI: Double = 15
        let maxBMI: Double = 40
        let clamped = min(max(bmiValue, minBMI), maxBMI)
        return CGFloat((clamped - minBMI) / (maxBMI - minBMI))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your BMI")
                .font(.system(size: 16, weight: .regular))
                .padding(.leading, 12)
                .padding(.bottom, 16)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .shadow(color: Color.gray.opacity(0.2), radius: 5)
                    .foregroundStyle(Color.white)
                    .frame(width: 320, height: 160)
                    .overlay {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Your weight is")
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: 110, height: 30)
                                        .foregroundStyle(bmiCategoryColor)
                                        .overlay {
                                            Text(bmiCategoryText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                }
                            }
                            Text(bmiText)
                                .font(.system(size: 20, weight: .medium))
                            BMIGradientBar(markerPosition: bmiNormalizedPosition)
                                .frame(height: 10)
                                .padding(.bottom, 20)
                            HStack(spacing: 8) {
                                LineReferenceValue(refColor: .blue, refText: "Underweight")
                                LineReferenceValue(refColor: .green, refText: "Healthy")
                                LineReferenceValue(refColor: .yellow, refText: "Overweight")
                                LineReferenceValue(refColor: .red, refText: "Obese")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
            }
        }
        .frame(width: 320)
    }
}

struct LineReferenceValue: View {
    var refColor: Color
    var refText: String
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(refColor)
            Text(refText)
                .font(.system(size: 10, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct BMIGradientBar: View {
    var markerPosition: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2, height: 20)
                    .offset(x: max(0, min(markerPosition, 1)) * (proxy.size.width - 2))
            }
        }
        .frame(width: 280, height: 10)
    }
}

enum BMIValue: String {
    case underweight = "Underweight"
    case normal = "Normal"
    case overweight = "Overweight"
    case obese = "Obese"

    init(bmi: Double) {
        switch bmi {
        case ..<18.5:
            self = .underweight
        case 18.5 ..< 25:
            self = .normal
        case 25 ..< 30:
            self = .overweight
        case 30...:
            self = .obese
        default:
            self = .underweight
        }
    }
}

enum BMIColor {
    case underweight
    case normal
    case overweight
    case obese

    init(bmiValue: BMIValue) {
        switch bmiValue {
        case .underweight:
            self = .underweight
        case .normal:
            self = .normal
        case .overweight:
            self = .overweight
        case .obese:
            self = .obese
        }
    }

    var color: Color {
        switch self {
        case .underweight:
            .blue
        case .normal:
            .green
        case .overweight:
            .yellow
        case .obese:
            .green
        }
    }
}

#Preview {
    BMIView()
}
