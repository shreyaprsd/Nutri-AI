//
//  CircularProgressRingView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 26/01/26.
//

import SwiftUI

struct CircularProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color

    init(
        progress: Double,
        lineWidth: CGFloat = 2,
        ringColor: Color = .blue,
        backgroundColor: Color = .gray.opacity(0.2)
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.ringColor = ringColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
