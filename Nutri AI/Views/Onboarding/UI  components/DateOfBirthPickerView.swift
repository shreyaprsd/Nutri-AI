import SwiftUI

struct DateOfBirthPickerView: View {
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int
    @Binding var selectedYear: Int

    private let months = [
        (1, "January"), (2, "February"), (3, "March"), (4, "April"),
        (5, "May"), (6, "June"), (7, "July"), (8, "August"),
        (9, "September"), (10, "October"), (11, "November"), (12, "December"),
    ]

    private var availableDays: [Int] {
        let maxDay = daysInMonth(month: selectedMonth, year: selectedYear)
        return Array(1 ... maxDay)
    }

    var body: some View {
        HStack {
            Picker("Month", selection: $selectedMonth) {
                ForEach(months, id: \.0) { month in
                    Text(month.1).tag(month.0)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: selectedMonth) { _, _ in
                adjustDayIfNeeded()
            }

            Picker("Day", selection: $selectedDay) {
                ForEach(availableDays, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.wheel)

            Picker("Year", selection: $selectedYear) {
                ForEach(1930 ... 2030, id: \.self) { year in
                    Text(verbatim: "\(year)").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: selectedYear) { _, _ in
                adjustDayIfNeeded()
            }
        }
        .padding()
    }

    private func daysInMonth(month: Int, year: Int) -> Int {
        let components = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return 31 }
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 31
    }

    private func adjustDayIfNeeded() {
        let maxDay = daysInMonth(month: selectedMonth, year: selectedYear)
        if selectedDay > maxDay {
            selectedDay = maxDay
        }
    }
}

#Preview {
    DateOfBirthPickerView(selectedMonth: .constant(7), selectedDay: .constant(3), selectedYear: .constant(2003))
}
