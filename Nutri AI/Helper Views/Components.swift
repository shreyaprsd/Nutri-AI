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
    @Environment(AppTheme.self) private var theme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(theme.buttonBackground)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.buttonBackground)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 130, height: 90)
            .background(theme.cardBackground)
            .cornerRadius(16)
        }
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
