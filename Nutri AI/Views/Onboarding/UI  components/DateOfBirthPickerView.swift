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
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            31
        case 4, 6, 9, 11:
            30
        case 2:
            isLeapYear(year: year) ? 29 : 28
        default:
            31
        }
    }

    private func isLeapYear(year: Int) -> Bool {
        if year % 400 == 0 {
            return true
        }
        if year % 100 == 0 {
            return false
        }
        if year % 4 == 0 {
            return true
        }
        return false
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
