import Charts
import SwiftData
import SwiftUI

struct GrowthMacroEntry: Identifiable {
    let id = UUID()
    let day: String
    let macro: MacroType
    let calories: Double
}

enum MacroType: String, CaseIterable {
    case protein = "Protein"
    case carbs = "Carbs"
    case fats = "Fats"

    var color: Color {
        switch self {
        case .protein:
            Color(red: 0.88, green: 0.38, blue: 0.38)
        case .carbs:
            Color(red: 0.90, green: 0.68, blue: 0.45)
        case .fats:
            Color(red: 0.45, green: 0.59, blue: 0.86)
        }
    }
}

struct GrowthBarGraphView: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) private var foodEntries: [NutritionModel]

    private var weekInterval: DateInterval? {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())
    }

    private var chartEntries: [GrowthMacroEntry] {
        guard let interval = weekInterval else {
            return []
        }
        let calendar = Calendar.current
        let filtered = foodEntries.filter { $0.createdAt >= interval.start && $0.createdAt < interval.end }
        var totalsByDay: [Date: (protein: Double, carbs: Double, fats: Double)] = [:]

        for entry in filtered {
            let dayStart = calendar.startOfDay(for: entry.createdAt)
            let multiplier = entry.servingMultiplier
            let proteinCalories = entry.nutrients.protein.total * multiplier * 4
            let carbCalories = entry.nutrients.carbs.total * multiplier * 4
            let fatCalories = entry.nutrients.fats.total * multiplier * 9
            var totals = totalsByDay[dayStart] ?? (0, 0, 0)
            totals.protein += proteinCalories
            totals.carbs += carbCalories
            totals.fats += fatCalories
            totalsByDay[dayStart] = totals
        }

        var entries: [GrowthMacroEntry] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        var day = interval.start
        for _ in 0 ..< 7 {
            let dayStart = calendar.startOfDay(for: day)
            let label = formatter.string(from: dayStart)
            let totals = totalsByDay[dayStart] ?? (0, 0, 0)

            entries.append(GrowthMacroEntry(day: label, macro: .protein, calories: totals.protein))
            entries.append(GrowthMacroEntry(day: label, macro: .carbs, calories: totals.carbs))
            entries.append(GrowthMacroEntry(day: label, macro: .fats, calories: totals.fats))

            day = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        }

        return entries
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
            .frame(width: 320)
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
