//
//  WeekCalendarView.swift
//  habit-streak
//
//  PRD §5.1 — week strip with paging (PRD §12); today white-filled; tap selects day.
//

import SwiftUI

struct WeekCalendarView: View {
    @Environment(HabitStore.self) private var store: HabitStore

    /// Stable origin for `pageOffsets` so tags do not drift when `selectedDate` changes.
    @State private var epochWeekStart: Date = Date()
    @State private var displayedWeekStart: Date = Date()

    private var cal: Calendar {
        DateHelpers.calendar(firstWeekday: store.weekStartsOn)
    }

    private let pageOffsets: [Int] = Array(-26...26)

    var body: some View {
        let selectionBinding = Binding<Date>(
            get: { displayedWeekStart },
            set: { newWeekStart in
                let normalized: Date = cal.startOfDay(for: newWeekStart)
                displayedWeekStart = normalized
                alignSelectedDateToSameWeekday(newWeekStart: normalized)
            }
        )

        VStack(spacing: 8) {
            TabView(selection: selectionBinding) {
                ForEach(pageOffsets, id: \.self) { offset in
                    weekPage(for: offset)
                        .tag(weekStart(forPageOffset: offset))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 88)
        }
        .onAppear {
            let sw: Date = DateHelpers.startOfWeek(containing: store.selectedDate, weekStartsOn: store.weekStartsOn)
            epochWeekStart = sw
            displayedWeekStart = sw
        }
        .onChange(of: store.selectedDate) { _, newDate in
            let sw: Date = DateHelpers.startOfWeek(containing: newDate, weekStartsOn: store.weekStartsOn)
            let delta: Int = weeksOffset(from: epochWeekStart, to: sw)
            if delta < -24 || delta > 24 {
                epochWeekStart = sw
            }
            displayedWeekStart = sw
        }
        .onChange(of: store.weekStartsOn) { _, _ in
            let sw: Date = DateHelpers.startOfWeek(containing: store.selectedDate, weekStartsOn: store.weekStartsOn)
            epochWeekStart = sw
            displayedWeekStart = sw
        }
    }

    private func weeksOffset(from start: Date, to end: Date) -> Int {
        let a: Date = cal.startOfDay(for: start)
        let b: Date = cal.startOfDay(for: end)
        let days: Int = cal.dateComponents([.day], from: a, to: b).day ?? 0
        return days / 7
    }

    private func weekStart(forPageOffset offset: Int) -> Date {
        let base: Date = cal.startOfDay(for: epochWeekStart)
        return cal.startOfDay(for: cal.date(byAdding: .weekOfYear, value: offset, to: base) ?? base)
    }

    private func alignSelectedDateToSameWeekday(newWeekStart: Date) {
        let weekday: Int = cal.component(.weekday, from: store.selectedDate)
        let startNorm: Date = cal.startOfDay(for: newWeekStart)
        let startWeekday: Int = cal.component(.weekday, from: startNorm)
        var delta: Int = weekday - startWeekday
        if delta < 0 {
            delta += 7
        }
        if let newDay = cal.date(byAdding: .day, value: delta, to: startNorm) {
            store.selectedDate = cal.startOfDay(for: newDay)
        }
    }

    @ViewBuilder
    private func weekPage(for offset: Int) -> some View {
        let weekStartDate: Date = weekStart(forPageOffset: offset)
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { column in
                let day: Date = cal.date(byAdding: .day, value: column, to: weekStartDate).map { cal.startOfDay(for: $0) } ?? weekStartDate
                dayColumn(date: day)
            }
        }
        .padding(.horizontal, 8)
    }

    /// One letter per column from the column’s actual date (avoids mismatched strip arrays / “?” fallbacks).
    private func weekdayLetter(for date: Date) -> String {
        let idx: Int = cal.component(.weekday, from: date) - 1
        let symbols: [String] = cal.veryShortWeekdaySymbols
        guard idx >= 0, idx < symbols.count else { return "" }
        return symbols[idx]
    }

    @ViewBuilder
    private func dayColumn(date: Date) -> some View {
        let todayStart: Date = cal.startOfDay(for: Date())
        let isToday: Bool = cal.isDate(date, inSameDayAs: todayStart)
        let isSelected: Bool = cal.isDate(date, inSameDayAs: store.selectedDate)

        Button {
            store.selectedDate = cal.startOfDay(for: date)
        } label: {
            VStack(spacing: 6) {
                Text(weekdayLetter(for: date))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
                Text("\(cal.component(.day, from: date))")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isToday || isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                    .frame(width: 36, height: 36)
                    .liquidGlass(
                        in: Circle(),
                        interactive: true,
                        tint: isToday ? AppColor.accentBlue : nil,
                        fallback: circleFill(isToday: isToday, isSelected: isSelected)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(accessibilityDayLabel(date: date)))
    }

    /// Pre-iOS 26 fallback fill (iOS 26+ uses Liquid Glass instead).
    private func circleFill(isToday: Bool, isSelected: Bool) -> Color {
        if isToday {
            return AppColor.accentBlue
        }
        if isSelected {
            return AppColor.bgTertiary
        }
        return Color.clear
    }

    private func accessibilityDayLabel(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
