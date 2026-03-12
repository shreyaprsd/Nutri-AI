//
//  GrowthChartBuilder.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/03/26.
//

import Foundation

struct GrowthChartBuilder {
    let calendar: Calendar

    func makeWeeklyEntries(from foodEntries: [NutritionModel], now: Date = .now) -> [GrowthMacroEntry] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }

        let filtered = foodEntries.filter { interval.contains($0.createdAt) }
        var totalsByDay: [Date: (protein: Double, carbs: Double, fats: Double)] = [:]

        for entry in filtered {
            let day = calendar.startOfDay(for: entry.createdAt)
            let multiplier = entry.servingMultiplier

            var totals = totalsByDay[day] ?? (0, 0, 0)
            totals.protein += entry.nutrients.protein.total * multiplier * 4
            totals.carbs += entry.nutrients.carbs.total * multiplier * 4
            totals.fats += entry.nutrients.fats.total * multiplier * 9
            totalsByDay[day] = totals
        }

        let formatter = DateFormatter()
        formatter.locale = calendar.locale ?? .current
        formatter.dateFormat = "EEE"

        return stride(from: 0, to: 7, by: 1).flatMap { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: interval.start)!
            let dayStart = calendar.startOfDay(for: day)
            let label = formatter.string(from: dayStart)
            let totals = totalsByDay[dayStart] ?? (0, 0, 0)

            return [
                GrowthMacroEntry(day: label, macro: .protein, calories: totals.protein),
                GrowthMacroEntry(day: label, macro: .carbs, calories: totals.carbs),
                GrowthMacroEntry(day: label, macro: .fats, calories: totals.fats),
            ]
        }
    }
}
