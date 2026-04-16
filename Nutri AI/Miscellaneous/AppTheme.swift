//
//  AppTheme.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 28/03/26.
//

import SwiftUI

struct AppTheme {
    // MARK: - Backgrounds

    let cardBackground = Color(.cardBackground)
    let subtleCardBackground = Color(.subtleCardBackground)

    // MARK: - Text

    let secondaryText = Color.secondary

    // MARK: - Buttons

    let primaryFill = Color.primary
    let primaryFillContent = Color(.systemBackground)

    // MARK: - Controls

    let toggleTint = Color.primary

    // MARK: - Borders & Strokes

    let border = Color(.separator)

    // MARK: - Shadows

    let shadow = Color.primary.opacity(0.1)
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
