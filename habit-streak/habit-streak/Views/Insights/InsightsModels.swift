//
//  InsightsModels.swift
//  habit-streak
//
//  PRD §5.4 — time range tab + period math for Insights.
//

import Foundation
import SwiftData

enum InsightsRangeTab: String, CaseIterable, Identifiable {
    case week = "W"
    case month = "M"
    case year = "Y"
    case all = "All"

    var id: String { rawValue }
}

enum InsightsPeriod {
    /// PRD §5.4 — current period for tab + offset (0 = period containing `reference`).
    static func dateInterval(
        tab: InsightsRangeTab,
        offset: Int,
        reference: Date = Date(),
        weekStartsOn: WeekStartDay,
        calendar: Calendar = .current,
        habitsForAll: [Habit] = []
    ) -> DateInterval {
        let refStart: Date = calendar.startOfDay(for: reference)
        switch tab {
        case .week:
            let thisWeek: Date = DateHelpers.startOfWeek(containing: refStart, weekStartsOn: weekStartsOn)
            let calW: Calendar = DateHelpers.calendar(firstWeekday: weekStartsOn)
            guard let weekStart: Date = calW.date(byAdding: .weekOfYear, value: -offset, to: thisWeek) else {
                return DateInterval(start: refStart, duration: 86400 * 7)
            }
            let ws: Date = calW.startOfDay(for: weekStart)
            let we: Date = DateHelpers.endOfWeek(startOfWeek: ws, weekStartsOn: weekStartsOn)
            return DateInterval(start: ws, end: calendar.startOfDay(for: we).addingTimeInterval(86400 - 1))
        case .month:
            let monthStart: Date = DateHelpers.startOfMonth(containing: refStart, calendar: calendar)
            guard let start: Date = calendar.date(byAdding: .month, value: -offset, to: monthStart) else {
                return DateInterval(start: refStart, duration: 86400 * 30)
            }
            let ms: Date = calendar.startOfDay(for: start)
            let me: Date = DateHelpers.endOfMonth(containing: ms, calendar: calendar)
            return DateInterval(start: ms, end: me.addingTimeInterval(86400 - 1))
        case .year:
            let parts: DateComponents = calendar.dateComponents([.year], from: refStart)
            let y: Int = parts.year ?? 2026
            var yc: DateComponents = DateComponents()
            yc.year = y - offset
            yc.month = 1
            yc.day = 1
            let ys: Date = calendar.date(from: yc) ?? refStart
            var endC: DateComponents = DateComponents()
            endC.year = y - offset
            endC.month = 12
            endC.day = 31
            let ye: Date = calendar.date(from: endC) ?? ys
            return DateInterval(start: calendar.startOfDay(for: ys), end: calendar.startOfDay(for: ye).addingTimeInterval(86400 - 1))
        case .all:
            let starts: [Date] = habitsForAll.map { calendar.startOfDay(for: $0.createdAt) }
            let start: Date = starts.min() ?? calendar.date(byAdding: .year, value: -1, to: refStart) ?? refStart
            return DateInterval(start: start, end: refStart.addingTimeInterval(86400 - 1))
        }
    }

    static func rangeLabel(for interval: DateInterval, tab: InsightsRangeTab) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if tab == .all {
            return "All time"
        }
        return "\(formatter.string(from: interval.start)) to \(formatter.string(from: interval.end))"
    }
}
