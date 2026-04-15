//
//  Components.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import SwiftUI

// to display options after clicking the "+" button
struct OptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(theme.primaryFill)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.primaryFill)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 130, height: 90)
            .background(theme.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var width: CGFloat = 310
    var height: CGFloat = 46
    var cornerRadius: CGFloat = 20
    @Environment(\.appTheme) private var theme

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(theme.primaryFillContent)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.primaryFill)
            )
    }
}

// to food image in the list view
struct FoodImage: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 116, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// to display macro in the list
struct FoodNutriView: View {
    let nutrition: String
    let image: String
    var body: some View {
        HStack {
            Text(image)
            Text(nutrition)
        }
        .font(.system(size: 12))
    }
}
