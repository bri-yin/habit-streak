//
//  Date+Helpers.swift
//  habit-streak
//

import Foundation

enum DateHelpers {
    /// PRD §5.1 / §4: `WeekDay` matches `Calendar.Component.weekday` (1 = Sunday).
    static func isHabitScheduled(_ habit: Habit, on day: Date, calendar: Calendar = .current) -> Bool {
        let d = calendar.startOfDay(for: day)
        switch habit.frequency {
        case .daily:
            let wd = calendar.component(.weekday, from: d)
            return habit.weekdays.contains { $0.rawValue == wd }
        case .weekly, .monthly:
            return true
        }
    }

    static func calendar(firstWeekday weekStartsOn: WeekStartDay) -> Calendar {
        var cal = Calendar.current
        cal.firstWeekday = weekStartsOn == .sunday ? 1 : 2
        return cal
    }

    /// Start of the week interval containing `date` (respects `firstWeekday`, PRD §4 weekly streak).
    static func startOfWeek(containing date: Date, weekStartsOn: WeekStartDay) -> Date {
        let calendar = Self.calendar(firstWeekday: weekStartsOn)
        let dayStart = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayStart)
        return calendar.date(from: parts) ?? dayStart
    }

    static func endOfWeek(startOfWeek: Date, weekStartsOn: WeekStartDay) -> Date {
        let calendar = Self.calendar(firstWeekday: weekStartsOn)
        guard let end = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else { return startOfWeek }
        return calendar.startOfDay(for: end)
    }

    static func startOfMonth(containing date: Date, calendar: Calendar = .current) -> Date {
        let dayStart = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month], from: dayStart)
        return calendar.date(from: parts) ?? dayStart
    }

    static func endOfMonth(containing date: Date, calendar: Calendar = .current) -> Date {
        let start = startOfMonth(containing: date, calendar: calendar)
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: start),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else { return start }
        return calendar.startOfDay(for: lastDay)
    }
}
