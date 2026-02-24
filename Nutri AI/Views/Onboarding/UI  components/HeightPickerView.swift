import SwiftUI

struct HeightPickerView: View {
    @Binding var heightInCm: Double
    @Binding var isMetric: Bool

    private let metricHeights = Array(60 ... 243)

    var body: some View {
        VStack {
            Text("Height")
                .font(.system(size: 14, weight: .medium))

            if isMetric {
                Picker("Height", selection: metricHeightBinding) {
                    ForEach(metricHeights, id: \.self) { height in
                        Text("\(height) cm").tag("\(height) cm")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120, height: 150)
            } else {
                HStack(spacing: 0) {
                    Picker("Feet", selection: createFeetBinding()) {
                        ForEach(2 ... 8, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 150)

                    Picker("Inches", selection: createInchesBinding()) {
                        ForEach(0 ... 11, id: \.self) { inches in
                            Text("\(inches) in").tag(inches)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 150)
                }
            }
        }
        .padding()
    }

    private var metricHeightBinding: Binding<String> {
        Binding(
            get: { "\(Int(heightInCm)) cm" },
            set: { newValue in
                if let value = Int(newValue.replacingOccurrences(of: " cm", with: "")) {
                    heightInCm = Double(value)
                }
            }
        )
    }

    private func createFeetBinding() -> Binding<Int> {
        Binding(
            get: {
                let totalInches = heightInCm / 2.54
                return Int(totalInches / 12)
            },
            set: { newFeet in
                let currentInches = Int((heightInCm / 2.54).truncatingRemainder(dividingBy: 12))
                let totalInches = Double(newFeet * 12 + currentInches)
                heightInCm = totalInches * 2.54
            }
        )
    }

    private func createInchesBinding() -> Binding<Int> {
        Binding(
            get: {
                let totalInches = heightInCm / 2.54
                return Int(totalInches.truncatingRemainder(dividingBy: 12))
            },
            set: { newInches in
                let currentFeet = Int(heightInCm / 2.54 / 12)
                let totalInches = Double(currentFeet * 12 + newInches)
                heightInCm = totalInches * 2.54
            }
        )
    }
}

#Preview {
    HeightPickerView(heightInCm: .constant(168), isMetric: .constant(true))
}
