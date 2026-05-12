//
//  ContentView.swift
//  habit-streak
//
//  Created by Brian Yin on 5/12/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .insights:
                    InsightsPlaceholderView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomNavBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
        .tint(AppColor.textPrimary)
    }
}

#Preview("App root") {
    ContentPreviewHost()
}

private struct ContentPreviewHost: View {
    private let modelContainer: ModelContainer
    private let habitStore: HabitStore

    init() {
        let schema: Schema = Schema([Habit.self, HabitCompletion.self])
        let configuration: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        modelContainer = container
        habitStore = HabitStore(modelContext: container.mainContext)
    }

    var body: some View {
        ContentView()
            .modelContainer(modelContainer)
            .environment(habitStore)
    }
}
