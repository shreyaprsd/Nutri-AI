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

// progressview that appears while waiting for the api to response
struct AnalysisProgressView: View {
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(
                        Color.gray.opacity(0.2),
                        lineWidth: 10
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 50, height: 50)
        }
        .onAppear {
            startRandomProgress()
        }
    }

    private func startRandomProgress() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            let randomIncrement = Double.random(in: 0.05 ... 0.15)

            progress += randomIncrement

            if progress >= 0.9 {
                progress = 0.9
                timer.invalidate()
            }
        }
    }
}

#Preview {
    AnalysisProgressView()
}
