//
//  ArchivedHabitsView.swift
//  habit-streak
//
//  PRD §5.6 — list archived habits with restore.
//

import SwiftData
import SwiftUI

struct ArchivedHabitsView: View {
    @Environment(HabitStore.self) private var store: HabitStore

    @Query(filter: #Predicate<Habit> { $0.archivedAt != nil }, sort: [SortDescriptor(\Habit.name)])
    private var archived: [Habit]

    var body: some View {
        ZStack {
            AppColor.bgPrimary.ignoresSafeArea()
            if archived.isEmpty {
                Text("No archived habits")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
            } else {
                List {
                    ForEach(archived, id: \.id) { habit in
                        HStack {
                            EmojiGlyphView(text: habit.emoji, fontSize: 22)
                                .frame(width: 28, height: 28)
                            Text(habit.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColor.textPrimary)
                            Spacer()
                            Button("Restore") {
                                store.restoreHabit(habit)
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppColor.accentBlue)
                        }
                        .listRowBackground(AppColor.bgSecondary)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(habit.name), archived")
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .navigationTitle("Archived habits")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
    }
}
