//
//  AppTheme.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 28/03/26.
//

import SwiftUI

struct AppTheme {
    // MARK: - Backgrounds

    var cardBackground: Color { Color("CardBackground") }
    var subtleCardBackground: Color { Color("SubtleCardBackground") }

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

// MARK: - Environment Integration

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
