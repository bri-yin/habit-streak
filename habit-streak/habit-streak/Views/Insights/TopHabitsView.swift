//
//  TopHabitsView.swift
//  habit-streak
//
//  PRD §5.4 — ranked habits with streak and completion rate.
//

import SwiftData
import SwiftUI

struct TopHabitsView: View {
    var habits: [Habit]
    var interval: DateInterval
    var store: HabitStore

    private func completionPercent(for habit: Habit) -> Double {
        let cal: Calendar = store.calendar
        let start: Date = cal.startOfDay(for: interval.start)
        let end: Date = cal.startOfDay(for: interval.end)
        let days: [Date] = DateHelpers.eachDay(from: interval.start, through: interval.end, calendar: cal)
        let scheduled: Int = days.filter { DateHelpers.isHabitScheduled(habit, on: $0, calendar: cal) }.count
        guard scheduled > 0 else { return 0 }
        let done: Int = habit.completions.filter {
            let d: Date = cal.startOfDay(for: $0.date)
            return d >= start && d <= end
        }.count
        return Double(done) / Double(scheduled) * 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top performing habits")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            if habits.isEmpty {
                Text("Add habits to see rankings.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
            } else {
                GlassCard {
                    VStack(spacing: 0) {
                        ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                            topRow(rank: index + 1, habit: habit, percent: completionPercent(for: habit))
                            if index < habits.count - 1 {
                                Divider().background(AppColor.textTertiary)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func topRow(rank: Int, habit: Habit, percent: Double) -> some View {
        let _ = habit.completions.count
        let streak: Int = store.streak(for: habit)
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 24, alignment: .leading)
            EmojiGlyphView(text: habit.emoji, fontSize: 22)
                .frame(width: 28, height: 28)
            Text(habit.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 8)
            HStack(spacing: 4) {
                EmojiGlyphView(text: "🔥", fontSize: 15)
                    .frame(width: 20, height: 20)
                Text("\(streak)")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
            }
            Text("\(Int(percent))%")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank), \(habit.name), streak \(streak), \(Int(percent)) percent completion")
    }
}
