//
//  ProgressBar.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/01/26.
//

import SwiftUI

struct ProgressBar: View {
    let current: Int
    let total: Int

    var progress: CGFloat {
        CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
            .clipShape(Capsule())
        }
        .frame(height: 4)
    }
}
