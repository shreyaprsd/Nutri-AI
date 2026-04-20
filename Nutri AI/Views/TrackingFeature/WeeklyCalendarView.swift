//
//  WeeklyCalendarView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 12/02/26.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private var currentWeek: [Date] {
        Self.buildWeek(for: selectedDate)
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 8
        ) {
            ForEach(currentWeek, id: \.self) { date in
                let isFuture = calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending

                DayView(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isFuture: isFuture
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if !isFuture { selectedDate = date }
                }
            }
        }
        .frame(width: 330)
    }

    private static func buildWeek(for date: Date) -> [Date] {
        let cal = Calendar.current
        guard let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else { return [] }
        return (0 ..< 7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let isFuture: Bool

    private var dayInitial: String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    private var dateNumber: String {
        date.formatted(.dateTime.day())
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if !isFuture {
                    Circle()
                        .stroke(
                            isSelected ? Color.primary : Color(.systemGray).opacity(0.5),
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: [3, 3]
                            )
                        )
                        .frame(width: 25, height: 25)
                }

                Text(dayInitial)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .frame(width: 25, height: 25)
            }

            Text(dateNumber)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
        }
        .foregroundColor(isFuture ? .gray.opacity(0.4) : .primary)
    }
}

#Preview {
    WeeklyCalendarView(selectedDate: .constant(Date()))
}
