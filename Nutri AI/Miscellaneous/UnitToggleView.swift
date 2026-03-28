//
//  UnitToggleView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/03/26.
//

import SwiftUI

struct UnitToggleView: View {
    @Binding var isMetric: Bool
    @Environment(AppTheme.self) private var theme

    var body: some View {
        HStack {
            Text("Imperial")
                .foregroundStyle(isMetric ? .secondary : .primary)
                .padding(.trailing, 40)
            Toggle("", isOn: $isMetric)
                .tint(theme.toggleTint)
                .labelsHidden()
            Text("Metric")
                .foregroundStyle(isMetric ? .primary : .secondary)
                .padding(.leading, 40)
        }
        .font(.system(size: 16, weight: .bold))
        .frame(maxWidth: .infinity)
    }
}
