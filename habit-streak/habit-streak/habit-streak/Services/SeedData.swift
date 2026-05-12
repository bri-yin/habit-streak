//
//  SeedData.swift
//  habit-streak
//

import Foundation
import SwiftData

enum UserDefaultsKeys {
    static let hasSeededInitialData: String = "hasSeededInitialData"
}

/// Deterministic PRNG (SplitMix64) so demo data matches across installs without relying on SDK `SeededRandomNumberGenerator` availability.
private struct DemoSeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z: UInt64 = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// PRD §9 seed dataset: fixed PRNG seed for deterministic completions.
enum SeedData {
    /// Fixed seed so demo completions are identical across installs (PRD §9).
    private static let demoRandomSeed: UInt64 = 0x015B115EED2026

    /// Initial install: seed only when `hasSeededInitialData` is unset/false **and** there are no habits (PRD §9 + clear-all behavior).
    @MainActor
    static func applyInitialSeedIfNeeded(modelContext: ModelContext) throws {
        let defaults = UserDefaults.standard
        let descriptor = FetchDescriptor<Habit>()
        let existing = try modelContext.fetch(descriptor)

        if !existing.isEmpty {
            if !defaults.bool(forKey: UserDefaultsKeys.hasSeededInitialData) {
                defaults.set(true, forKey: UserDefaultsKeys.hasSeededInitialData)
            }
            return
        }

        if defaults.bool(forKey: UserDefaultsKeys.hasSeededInitialData) {
            return
        }

        try insertDemoHabitsAndCompletions(modelContext: modelContext)
        defaults.set(true, forKey: UserDefaultsKeys.hasSeededInitialData)
    }

    /// PRD §5.6 / §9: replace persisted habits with the demo dataset regardless of flags.
    @MainActor
    static func resetToDemoData(modelContext: ModelContext) throws {
        try modelContext.delete(model: Habit.self)
        try insertDemoHabitsAndCompletions(modelContext: modelContext)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeededInitialData)
    }

    @MainActor
    private static func insertDemoHabitsAndCompletions(modelContext: ModelContext) throws {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        let gym = Habit(name: "Gym Workout", emoji: "🏋️", frequency: .daily)
        gym.weekdays = [.monday, .wednesday, .friday]
        gym.order = 0

        let sleep = Habit(name: "7h Sleep", emoji: "😴", frequency: .daily)
        sleep.weekdays = WeekDay.allCases
        sleep.order = 1

        let run = Habit(name: "Run", emoji: "🏃", frequency: .daily)
        run.weekdays = [.tuesday, .thursday, .saturday]
        run.order = 2

        let lichess = Habit(name: "Lichess Puzzles 15m", emoji: "♟️", frequency: .daily)
        lichess.weekdays = WeekDay.allCases
        lichess.order = 3

        let read = Habit(name: "Read a Book", emoji: "📖", frequency: .daily)
        read.weekdays = WeekDay.allCases
        read.order = 4

        let habitsInOrder: [(habit: Habit, rate: Double)] = [
            (gym, 0.85),
            (sleep, 0.70),
            (run, 0.60),
            (lichess, 0.90),
            (read, 0.55),
        ]

        for pair in habitsInOrder {
            modelContext.insert(pair.habit)
        }

        var rng = DemoSeededGenerator(seed: demoRandomSeed)

        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -(29 - dayOffset), to: todayStart) else { continue }
            let weekday = calendar.component(.weekday, from: day)
            guard let weekDay = WeekDay(rawValue: weekday) else { continue }

            for pair in habitsInOrder {
                let habit = pair.habit
                guard habit.weekdays.contains(weekDay) else { continue }
                if Double.random(in: 0..<1, using: &rng) < pair.rate {
                    let completion = HabitCompletion(date: day, habit: habit)
                    modelContext.insert(completion)
                }
            }
        }

        try modelContext.save()
    }
}
