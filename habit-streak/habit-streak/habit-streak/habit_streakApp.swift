//
//  habit_streakApp.swift
//  habit-streak
//
//  Created by Brian Yin on 5/12/26.
//

import SwiftData
import SwiftUI

@main
@MainActor
struct habit_streakApp: App {
    private let modelContainer: ModelContainer
    private let habitStore: HabitStore

    init() {
        do {
            modelContainer = try ModelContainer(for: Habit.self, HabitCompletion.self)
            try SeedData.applyInitialSeedIfNeeded(modelContext: modelContainer.mainContext)
            habitStore = HabitStore(modelContext: modelContainer.mainContext)
        } catch {
            fatalError("Failed to set up persistence: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(habitStore)
        }
        .modelContainer(modelContainer)
    }
}
