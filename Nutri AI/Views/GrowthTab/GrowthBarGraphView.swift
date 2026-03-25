import Charts
import SwiftData
import SwiftUI

struct GrowthMacroEntry: Identifiable {
    let id = UUID()
    let day: String
    let macro: MacroType
    let calories: Double
}

struct GrowthBarGraphView: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) private var foodEntries: [NutritionModel]

    private let chartBuilder = GrowthChartBuilder(calendar: .current)

    private var chartEntries: [GrowthMacroEntry] {
        chartBuilder.makeWeeklyEntries(from: foodEntries)
    }

    private var totalCaloriesText: String {
        let total = chartEntries.reduce(0) { $0 + $1.calories }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: total)) ?? "0"
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("This week")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.black)
                .frame(width: 320, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text("Total Calories")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.black)
                    .padding(.leading, 12)
                    .padding(.bottom, 16)
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(totalCaloriesText)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.black)
                    Text("cals")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.gray)
                }

                Chart(chartEntries) { entry in
                    BarMark(
                        x: .value("Day", entry.day),
                        y: .value("Calories", entry.calories)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Macro", entry.macro.rawValue))
                }
                .chartForegroundStyleScale([
                    MacroType.protein.rawValue: MacroType.protein.color,
                    MacroType.carbs.rawValue: MacroType.carbs.color,
                    MacroType.fats.rawValue: MacroType.fats.color,
                ])
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.gray.opacity(0.35))
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 180)

                HStack(spacing: 20) {
                    ForEach(MacroType.allCases, id: \.self) { macro in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(macro.color)
                                .frame(width: 8, height: 8)
                            Text(macro.rawValue)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 0)
            )
        }
    }
}

#Preview {
    GrowthBarGraphView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
