//
//  HabitStore+Analytics.swift
//  habit-streak
//
//  PRD §6 — export, completion rate, top habits; PRD §5.4 — heatmap inputs.
//

import Foundation
import SwiftData
import UserNotifications

extension HabitStore {
    /// PRD §5.6 — export all habits and completions as JSON.
    func exportJSON() throws -> Data {
        let habitDescriptor: FetchDescriptor<Habit> = FetchDescriptor<Habit>()
        let habits: [Habit] = try modelContext.fetch(habitDescriptor)
        let completionDescriptor: FetchDescriptor<HabitCompletion> = FetchDescriptor<HabitCompletion>()
        let completions: [HabitCompletion] = try modelContext.fetch(completionDescriptor)

        let habitRecords: [HabitExportRecord] = habits.map { h in
            HabitExportRecord(
                id: h.id,
                name: h.name,
                emoji: h.emoji,
                frequencyRaw: h.frequencyRaw,
                weekdaysRaw: h.weekdaysRaw,
                countPerPeriod: h.countPerPeriod,
                reminderEnabled: h.reminderEnabled,
                reminderHour: h.reminderHour,
                reminderMinute: h.reminderMinute,
                createdAt: h.createdAt,
                archivedAt: h.archivedAt,
                order: h.order
            )
        }
        let completionRecords: [HabitCompletionExportRecord] = completions.compactMap { c in
            guard let hid: UUID = c.habit?.id else { return nil }
            return HabitCompletionExportRecord(id: c.id, habitId: hid, date: c.date, completedAt: c.completedAt)
        }
        let payload: HabitDataExport = HabitDataExport(
            exportVersion: 1,
            exportedAt: Date(),
            habits: habitRecords,
            completions: completionRecords
        )
        let encoder: JSONEncoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    /// PRD §5.6 — wipe SwiftData store and notification schedule.
    func clearAllData() throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        try modelContext.delete(model: Habit.self)
        try modelContext.save()
    }

    /// Re-schedule reminders for all active habits (PRD §5.7).
    func rescheduleAllRemindersForActiveHabits() throws {
        let descriptor: FetchDescriptor<Habit> = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.archivedAt == nil }
        )
        let habits: [Habit] = try modelContext.fetch(descriptor)
        NotificationService.shared.rescheduleAllActiveReminders(habits: habits)
    }

    /// PRD §5.4 — total completions in `interval` (all habits).
    func completionCount(in interval: DateInterval) throws -> Int {
        let start: Date = calendar.startOfDay(for: interval.start)
        let end: Date = calendar.startOfDay(for: interval.end)
        let descriptor: FetchDescriptor<HabitCompletion> = FetchDescriptor<HabitCompletion>(
            predicate: #Predicate<HabitCompletion> { c in c.date >= start && c.date <= end }
        )
        let list: [HabitCompletion] = try modelContext.fetch(descriptor)
        return list.filter { $0.habit?.archivedAt == nil }.count
    }

    /// PRD §5.4 — sum of per-day scheduled slots for active habits in `interval`.
    func scheduledHabitDays(in interval: DateInterval, habits: [Habit]) -> Int {
        let days: [Date] = DateHelpers.eachDay(from: interval.start, through: interval.end, calendar: calendar)
        var total: Int = 0
        for habit in habits {
            for day in days where habit.archivedAt == nil {
                if DateHelpers.isHabitScheduled(habit, on: day, calendar: calendar) {
                    total += 1
                }
            }
        }
        return total
    }

    /// PRD §5.4 — `completions / scheduledHabitDays × 100` for active habits in range.
    func completionRate(in interval: DateInterval, habits: [Habit]) throws -> Double {
        let active: [Habit] = habits.filter { $0.archivedAt == nil }
        let scheduled: Int = scheduledHabitDays(in: interval, habits: active)
        guard scheduled > 0 else { return 0 }
        let done: Int = try completionCount(in: interval)
        return min(100, Double(done) / Double(scheduled) * 100)
    }

    /// PRD §5.4 — per-habit completion rate in range; sort descending.
    func topPerformingHabits(in interval: DateInterval, habits: [Habit]) throws -> [Habit] {
        let active: [Habit] = habits.filter { $0.archivedAt == nil }
        let start: Date = calendar.startOfDay(for: interval.start)
        let end: Date = calendar.startOfDay(for: interval.end)

        func rate(for habit: Habit) -> Double {
            let scheduled: Int = DateHelpers.eachDay(from: interval.start, through: interval.end, calendar: calendar)
                .filter { DateHelpers.isHabitScheduled(habit, on: $0, calendar: calendar) }
                .count
            guard scheduled > 0 else { return 0 }
            let done: Int = habit.completions.filter {
                let d: Date = calendar.startOfDay(for: $0.date)
                return d >= start && d <= end
            }.count
            return Double(done) / Double(scheduled) * 100
        }

        return active.sorted { rate(for: $0) > rate(for: $1) }
    }

    /// PRD §5.4 — raw completion counts per calendar day (all non-archived habits), keyed by start-of-day.
    func completionCountsByDay() throws -> [Date: Int] {
        let descriptor: FetchDescriptor<HabitCompletion> = FetchDescriptor<HabitCompletion>()
        let all: [HabitCompletion] = try modelContext.fetch(descriptor)
        var map: [Date: Int] = [:]
        for c in all {
            guard c.habit?.archivedAt == nil else { continue }
            let day: Date = calendar.startOfDay(for: c.date)
            map[day, default: 0] += 1
        }
        return map
    }

    /// PRD §5.4 — 7 rows × 26 columns; cell value = total completions that day across habits.
    func heatmapGrid(weekStartsOn: WeekStartDay, anchorDate: Date = Date()) throws -> [[Int]] {
        let cal: Calendar = DateHelpers.calendar(firstWeekday: weekStartsOn)
        let anchorStart: Date = DateHelpers.startOfWeek(containing: anchorDate, weekStartsOn: weekStartsOn)
        let oldestWeekStart: Date = cal.date(byAdding: .weekOfYear, value: -25, to: cal.startOfDay(for: anchorStart)) ?? anchorStart
        let countsByDay: [Date: Int] = try completionCountsByDay()

        var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 26), count: 7)
        for col in 0..<26 {
            guard let weekStart: Date = cal.date(byAdding: .weekOfYear, value: col, to: oldestWeekStart) else { continue }
            let ws: Date = cal.startOfDay(for: weekStart)
            for row in 0..<7 {
                guard let day: Date = cal.date(byAdding: .day, value: row, to: ws) else { continue }
                let key: Date = cal.startOfDay(for: day)
                grid[row][col] = countsByDay[key] ?? 0
            }
        }
        return grid
    }

    /// PRD §5.4 — one completion ratio per calendar day in `interval` (all active habits).
    func dailyCompletionRatios(in interval: DateInterval, habits: [Habit]) throws -> [(date: Date, ratio: Double)] {
        let active: [Habit] = habits.filter { $0.archivedAt == nil }
        let days: [Date] = DateHelpers.eachDay(from: interval.start, through: interval.end, calendar: calendar)

        var result: [(Date, Double)] = []
        for day in days {
            let scheduled: Int = active.filter { DateHelpers.isHabitScheduled($0, on: day, calendar: calendar) }.count
            guard scheduled > 0 else {
                result.append((day, 0))
                continue
            }
            var done: Int = 0
            for habit in active {
                if habit.completions.contains(where: { calendar.startOfDay(for: $0.date) == day }) {
                    done += 1
                }
            }
            result.append((day, Double(done) / Double(scheduled) * 100))
        }
        return result
    }

    /// Completion ratio aggregated by calendar month in `interval` (all active habits).
    /// Used for a Health-style "Y / All" chart to avoid rendering hundreds of daily bars.
    func monthlyCompletionRatios(in interval: DateInterval, habits: [Habit]) throws -> [(date: Date, ratio: Double)] {
        let active: [Habit] = habits.filter { $0.archivedAt == nil }
        let cal: Calendar = calendar
        let startMonth: Date = DateHelpers.startOfMonth(containing: interval.start, calendar: cal)
        let endMonth: Date = DateHelpers.startOfMonth(containing: interval.end, calendar: cal)

        var result: [(Date, Double)] = []
        var cursor: Date = cal.startOfDay(for: startMonth)
        while cursor <= endMonth {
            let monthStart: Date = DateHelpers.startOfMonth(containing: cursor, calendar: cal)
            let monthEnd: Date = DateHelpers.endOfMonth(containing: cursor, calendar: cal)
            let days: [Date] = DateHelpers.eachDay(from: monthStart, through: monthEnd, calendar: cal)

            var scheduled: Int = 0
            var done: Int = 0
            for day in days {
                let scheduledHabits: [Habit] = active.filter { DateHelpers.isHabitScheduled($0, on: day, calendar: cal) }
                scheduled += scheduledHabits.count
                for habit in scheduledHabits {
                    if habit.completions.contains(where: { cal.startOfDay(for: $0.date) == day }) {
                        done += 1
                    }
                }
            }

            let ratio: Double = scheduled == 0 ? 0 : Double(done) / Double(scheduled) * 100
            result.append((monthStart, min(100, ratio)))

            guard let next = cal.date(byAdding: .month, value: 1, to: monthStart) else { break }
            cursor = cal.startOfDay(for: next)
        }
        return result
    }
}
