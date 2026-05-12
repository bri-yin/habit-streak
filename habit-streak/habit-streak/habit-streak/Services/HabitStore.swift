//
//  HabitStore.swift
//  habit-streak
//
//  PRD §6 — mutations and derived streak; views read habits via @Query.
//

import Foundation
import Observation
import SwiftData

private enum HabitStoreUserDefaults {
    static let weekStartsOnRaw: String = "weekStartsOnRaw"
}

/// Outcome of `toggleCompletion` for UI (PRD §5.1 toast + row haptics).
struct ToggleCompletionResult: Equatable {
    /// After the toggle, whether this habit is completed on that day.
    var isCompleted: Bool
    /// `true` only when a completion was **added** and no habit had any completion on that calendar day before (PRD §5.1).
    var isFirstCompletionOfCalendarDay: Bool
}

@Observable
@MainActor
final class HabitStore {
    var modelContext: ModelContext
    var selectedDate: Date
    var weekStartsOn: WeekStartDay

    private let calendar: Calendar = .current

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.selectedDate = Calendar.current.startOfDay(for: Date())
        self.weekStartsOn = .sunday
        loadPreferences()
    }

    func loadPreferences() {
        if let raw = UserDefaults.standard.string(forKey: HabitStoreUserDefaults.weekStartsOnRaw),
           let value = WeekStartDay(rawValue: raw) {
            weekStartsOn = value
        }
    }

    func saveWeekStartsOnPreference(_ value: WeekStartDay) {
        weekStartsOn = value
        UserDefaults.standard.set(value.rawValue, forKey: HabitStoreUserDefaults.weekStartsOnRaw)
    }

    func streak(for habit: Habit) -> Int {
        StreakCalculator.streak(for: habit, weekStartsOn: weekStartsOn, calendar: calendar, today: Date())
    }

    func isCompleted(habit: Habit, date: Date) -> Bool {
        let d = calendar.startOfDay(for: date)
        return habit.completions.contains { calendar.startOfDay(for: $0.date) == d }
    }

    /// PRD §5.1 / §6 — insert or remove completion for this habit on `date` (start-of-day normalized).
    func toggleCompletion(habit: Habit, date: Date) throws -> ToggleCompletionResult {
        let day = calendar.startOfDay(for: date)
        let wasCompleted: Bool = isCompleted(habit: habit, date: day)

        if wasCompleted {
            let toDelete: [HabitCompletion] = habit.completions.filter { calendar.startOfDay(for: $0.date) == day }
            for c in toDelete {
                modelContext.delete(c)
            }
            try modelContext.save()
            return ToggleCompletionResult(isCompleted: false, isFirstCompletionOfCalendarDay: false)
        } else {
            let countBefore: Int = try countAllCompletions(on: day)
            let completion = HabitCompletion(date: day, habit: habit)
            modelContext.insert(completion)
            try modelContext.save()
            let isFirst: Bool = countBefore == 0
            return ToggleCompletionResult(isCompleted: true, isFirstCompletionOfCalendarDay: isFirst)
        }
    }

    private func countAllCompletions(on day: Date) throws -> Int {
        let target: Date = calendar.startOfDay(for: day)
        let descriptor = FetchDescriptor<HabitCompletion>(predicate: #Predicate<HabitCompletion> { c in c.date == target })
        return try modelContext.fetch(descriptor).count
    }

    func addHabit(_ habit: Habit) {
        modelContext.insert(habit)
        try? modelContext.save()
    }

    func updateHabit(_ habit: Habit) {
        try? modelContext.save()
    }

    func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
    }

    func archiveHabit(_ habit: Habit) {
        habit.archivedAt = Date()
        try? modelContext.save()
    }

    func restoreHabit(_ habit: Habit) {
        habit.archivedAt = nil
        try? modelContext.save()
    }

    func reorderHabits(_ habits: [Habit]) {
        for (index, habit) in habits.enumerated() {
            habit.order = index
        }
        try? modelContext.save()
    }

    /// PRD §5.1 / §6 — reorder after `.onMove` on the visible (scheduled) list; preserves relative order of habits not shown that day.
    func reorderHabits(afterMoving orderedVisible: [Habit]) throws {
        let subsetIds: Set<UUID> = Set(orderedVisible.map(\.id))
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.archivedAt == nil },
            sortBy: [SortDescriptor(\Habit.order)]
        )
        let allActive: [Habit] = try modelContext.fetch(descriptor)
        let others: [Habit] = allActive.filter { !subsetIds.contains($0.id) }.sorted { $0.order < $1.order }
        var index: Int = 0
        for habit in orderedVisible {
            habit.order = index
            index += 1
        }
        for habit in others {
            habit.order = index
            index += 1
        }
        try modelContext.save()
    }

    /// PRD §9 / §5.6 — restore demo dataset (used from Settings later).
    func resetToSeedData() throws {
        try SeedData.resetToDemoData(modelContext: modelContext)
    }
}
