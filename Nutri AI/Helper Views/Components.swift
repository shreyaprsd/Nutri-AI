//
//  Components.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import SwiftUI

struct OptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.black)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 130, height: 90)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct FoodImage: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 105, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.trailing, 193)
            .padding(.leading, 12)
    }
}

struct FoodNutriView: View {
    let nutrition: String
    let image: String
    var body: some View {
        HStack {
            Text(image)
            Text(nutrition)
        }
    }
}

#Preview {
    OptionButton(
        icon: "camera.fill",
        title: "Take Photo",
        action: {
            print("Button tapped")
        }
    )
}
