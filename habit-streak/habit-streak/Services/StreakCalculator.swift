//
//  StreakCalculator.swift
//  habit-streak
//
//  PRD §4 — pure streak logic for daily, weekly, and monthly habits.
//

import Foundation

enum StreakCalculator {
    /// Current streak for `habit` as of `today` (PRD §4).
    static func streak(
        for habit: Habit,
        weekStartsOn: WeekStartDay,
        calendar: Calendar = .current,
        today: Date = Date()
    ) -> Int {
        let cal = calendar
        let todayStart = cal.startOfDay(for: today)
        let modelCreatedStart = cal.startOfDay(for: habit.createdAt)
        let completionDayStarts: [Date] = habit.completions.map { cal.startOfDay(for: $0.date) }
        /// Streak must be able to count completions before `createdAt` (e.g. seed backfill, imports).
        let streakLowerBound: Date = {
            guard let earliest: Date = completionDayStarts.min() else { return modelCreatedStart }
            return min(modelCreatedStart, earliest)
        }()

        switch habit.frequency {
        case .daily:
            return dailyStreak(
                weekdayInts: Set(habit.weekdays.map(\.rawValue)),
                completionDayStarts: completionDayStarts,
                today: todayStart,
                lowerBound: streakLowerBound,
                calendar: cal
            )
        case .weekly:
            return weeklyStreak(
                countPerPeriod: max(1, habit.countPerPeriod),
                completionDayStarts: completionDayStarts,
                today: todayStart,
                weekStartsOn: weekStartsOn
            )
        case .monthly:
            return monthlyStreak(
                countPerPeriod: max(1, habit.countPerPeriod),
                completionDayStarts: completionDayStarts,
                today: todayStart,
                calendar: cal
            )
        }
    }

    // MARK: - Daily

    /// Consecutive **scheduled** days completed up to `today`; non-scheduled days are skipped (PRD §4).
    /// If **today** is scheduled but not yet completed, the streak is still counted from **yesterday** backward
    /// so the flame counter stays accurate until the user misses a past scheduled day.
    /// - Parameter lowerBound: Earliest calendar day to walk back to (see `streakLowerBound` in `streak(for:)`).
    private static func dailyStreak(
        weekdayInts: Set<Int>,
        completionDayStarts: [Date],
        today: Date,
        lowerBound: Date,
        calendar: Calendar
    ) -> Int {
        func hasCompletion(on day: Date) -> Bool {
            completionDayStarts.contains { calendar.isDate($0, inSameDayAs: day) }
        }

        var streak: Int = 0
        var d: Date = today
        while d >= lowerBound {
            let weekday: Int = calendar.component(.weekday, from: d)
            if !weekdayInts.contains(weekday) {
                guard let prev = calendar.date(byAdding: .day, value: -1, to: d) else { break }
                d = calendar.startOfDay(for: prev)
                continue
            }
            if hasCompletion(on: d) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: d) else { break }
                d = calendar.startOfDay(for: prev)
                continue
            }
            if calendar.isDate(d, inSameDayAs: today) {
                guard let prev = calendar.date(byAdding: .day, value: -1, to: d) else { break }
                d = calendar.startOfDay(for: prev)
                continue
            }
            break
        }
        return streak
    }

    // MARK: - Weekly

    /// Consecutive weeks with completion count ≥ `countPerPeriod`. Current open week counts if the partial interval already meets the goal; closed weeks must meet in full (PRD §4).
    private static func weeklyStreak(
        countPerPeriod: Int,
        completionDayStarts: [Date],
        today: Date,
        weekStartsOn: WeekStartDay
    ) -> Int {
        let cal = DateHelpers.calendar(firstWeekday: weekStartsOn)
        let todayStart = cal.startOfDay(for: today)

        var streak: Int = 0
        let currentWeekStart = DateHelpers.startOfWeek(containing: today, weekStartsOn: weekStartsOn)
        let currentWeekEnd = DateHelpers.endOfWeek(startOfWeek: currentWeekStart, weekStartsOn: weekStartsOn)
        let partialEnd = min(currentWeekEnd, todayStart)
        let currentCount = countCompletions(from: currentWeekStart, through: partialEnd, completionDayStarts: completionDayStarts, calendar: cal)
        if currentCount >= countPerPeriod {
            streak += 1
        }

        var weekStart = cal.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
        while true {
            let weekEnd = DateHelpers.endOfWeek(startOfWeek: weekStart, weekStartsOn: weekStartsOn)
            let c = countCompletions(from: weekStart, through: weekEnd, completionDayStarts: completionDayStarts, calendar: cal)
            if c >= countPerPeriod {
                streak += 1
                guard let prev = cal.date(byAdding: .weekOfYear, value: -1, to: weekStart) else { break }
                weekStart = prev
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Monthly

    /// Consecutive calendar months with completion count ≥ `countPerPeriod`. Current month uses partial range through `today` (PRD §4).
    private static func monthlyStreak(
        countPerPeriod: Int,
        completionDayStarts: [Date],
        today: Date,
        calendar: Calendar
    ) -> Int {
        let todayStart = calendar.startOfDay(for: today)
        var streak: Int = 0

        let monthStart = DateHelpers.startOfMonth(containing: today, calendar: calendar)
        let monthEndFull = DateHelpers.endOfMonth(containing: today, calendar: calendar)
        let partialEnd = min(monthEndFull, todayStart)
        let currentCount = countCompletions(from: monthStart, through: partialEnd, completionDayStarts: completionDayStarts, calendar: calendar)
        if currentCount >= countPerPeriod {
            streak += 1
        }

        guard let dayBeforeThisMonth = calendar.date(byAdding: .day, value: -1, to: monthStart) else { return streak }
        var closedMonthStart = DateHelpers.startOfMonth(containing: dayBeforeThisMonth, calendar: calendar)

        while true {
            let closedMonthEnd = DateHelpers.endOfMonth(containing: closedMonthStart, calendar: calendar)
            let c = countCompletions(from: closedMonthStart, through: closedMonthEnd, completionDayStarts: completionDayStarts, calendar: calendar)
            if c >= countPerPeriod {
                streak += 1
                guard let before = calendar.date(byAdding: .day, value: -1, to: closedMonthStart) else { break }
                closedMonthStart = DateHelpers.startOfMonth(containing: before, calendar: calendar)
            } else {
                break
            }
        }
        return streak
    }

    private static func countCompletions(
        from start: Date,
        through end: Date,
        completionDayStarts: [Date],
        calendar: Calendar
    ) -> Int {
        let s = calendar.startOfDay(for: start)
        let e = calendar.startOfDay(for: end)
        return completionDayStarts.reduce(0) { partial, day in
            let d = calendar.startOfDay(for: day)
            if d >= s && d <= e {
                return partial + 1
            }
            return partial
        }
    }
}
