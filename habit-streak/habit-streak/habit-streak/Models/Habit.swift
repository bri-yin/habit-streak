//
//  Habit.swift
//  habit-streak
//

import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
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

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []

    var frequency: FrequencyMode {
        get { FrequencyMode(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }

    var weekdays: [WeekDay] {
        get { weekdaysRaw.compactMap { WeekDay(rawValue: $0) } }
        set { weekdaysRaw = newValue.map { $0.rawValue } }
    }

    init(name: String, emoji: String, frequency: FrequencyMode) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.frequencyRaw = frequency.rawValue
        self.weekdaysRaw = WeekDay.allCases.map { $0.rawValue }
        self.countPerPeriod = 1
        self.reminderEnabled = false
        self.reminderHour = nil
        self.reminderMinute = nil
        self.createdAt = Date()
        self.archivedAt = nil
        self.order = 0
    }
}
