//
//  AppTheme.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 28/03/26.
//

import Observation
import SwiftUI

@Observable
final class AppTheme {
    // MARK: - Backgrounds

    var cardBackground: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor.white
        })
    }
    var subtleCardBackground: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor.gray.withAlphaComponent(0.1)
        })
    }

    // MARK: - Text

    var secondaryText: Color { Color.secondary }

    // MARK: - Buttons

    var buttonBackground: Color { Color.primary }
    var buttonForeground: Color { Color(.systemBackground) }

    // MARK: - Controls

    var toggleTint: Color { Color(.darkGray) }

    // MARK: - Borders & Strokes

    var border: Color { Color(.separator) }

    // MARK: - Shadows

    var shadow: Color { Color.primary.opacity(0.1) }
}
