//
//  DataExportModels.swift
//  habit-streak
//
//  PRD §5.6 / §6 — JSON export payload (Codable).
//

import Foundation

struct HabitDataExport: Codable {
    var exportVersion: Int
    var exportedAt: Date
    var habits: [HabitExportRecord]
    var completions: [HabitCompletionExportRecord]
}

struct HabitExportRecord: Codable {
    var id: UUID
    var name: String
    var emoji: String
    var frequencyRaw: String
    var weekdaysRaw: [Int]
    var countPerPeriod: Int
    var reminderEnabled: Bool
    var reminderHour: Int?
    var reminderMinute: Int?
    var createdAt: Date
    var archivedAt: Date?
    var order: Int
}

struct HabitCompletionExportRecord: Codable {
    var id: UUID
    var habitId: UUID
    var date: Date
    var completedAt: Date
}
