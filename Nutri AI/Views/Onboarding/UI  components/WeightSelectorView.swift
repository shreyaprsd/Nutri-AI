//
//  WeightSelectorView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 23/02/26.
//

import SwiftUI

struct WeightSelectorView: View {
    @Binding var weight: Double
    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    let minWeight: Double
    let maxWeight: Double
    let step: Double

    init(weight: Binding<Double>, minWeight: Double = 30.0, maxWeight: Double = 200.0, step: Double = 0.5) {
        _weight = weight
        self.minWeight = minWeight
        self.maxWeight = maxWeight
        self.step = step
    }

    var body: some View {
        HStack {
            Button {
                isEditing = false
                isFocused = false
                incrementWeight()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.black)
            }
            .padding(20)

            if isEditing {
                TextField("", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .regular))
                    .frame(width: 90)
                    .focused($isFocused)
            } else {
                Button {
                    isEditing = true
                    isFocused = true
                } label: {
                    Text(verbatim: String(format: "%.1f", weight))
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Color.black)
                        .frame(width: 90)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Button {
                isFocused = false
                isEditing = false
                decrementWeight()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.black)
            }
            .padding(20)
        }
    }

    private func incrementWeight() {
        if weight + step <= maxWeight {
            weight += step
        }
    }

    private func decrementWeight() {
        if weight - step >= minWeight {
            weight -= step
        }
    }
}
