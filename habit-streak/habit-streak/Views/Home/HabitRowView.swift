//
//  HabitRowView.swift
//  habit-streak
//
//  PRD §5.1 — row layout, checkbox, swipe actions, context menu, ShareLink (PRD §5.5).
//

import SwiftData
import SwiftUI
import UIKit

struct HabitRowView: View {
    @Bindable var habit: Habit
    var selectedDate: Date
    var store: HabitStore
    var onToggleResult: (ToggleCompletionResult) -> Void
    var onRequestReorder: () -> Void
    var onEdit: () -> Void

    @State private var showArchiveConfirm: Bool = false
    @State private var showDeleteConfirm: Bool = false

    private var isCompleted: Bool {
        _ = habit.completions.count
        return store.isCompleted(habit: habit, date: selectedDate)
    }

    private var streakCount: Int {
        _ = habit.completions.count
        return store.streak(for: habit)
    }

    private var streakUnitAccessibility: String {
        switch habit.frequency {
        case .daily:
            return "\(streakCount) days"
        case .weekly:
            return "\(streakCount) weeks"
        case .monthly:
            return "\(streakCount) months"
        }
    }

    private var shareMessage: String {
        let n: Int = streakCount
        let unit: String
        switch habit.frequency {
        case .daily:
            unit = n == 1 ? "1 day" : "\(n) days"
        case .weekly:
            unit = n == 1 ? "1 week" : "\(n) weeks"
        case .monthly:
            unit = n == 1 ? "1 month" : "\(n) months"
        }
        return "I've kept up my \(habit.name) streak for \(unit)!"
    }

    /// Emoji kept outside row label for reliable rendering.
    private var displayEmoji: String {
        let trimmed: String = habit.emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "⭐️"
        }
        return trimmed
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            checkboxButton

            EmojiGlyphView(text: displayEmoji, fontSize: 26)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            rowLabel
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(AppColor.bgPrimary)
        .listRowSeparator(.hidden)
        .contextMenu {
            rowActions
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Edit") {
                onEdit()
            }
            .tint(AppColor.accentBlue)
            Button("Delete", role: .destructive) {
                showDeleteConfirm = true
            }
        }
        .confirmationDialog(
            "Archive \(habit.name)? You can restore it later from Settings.",
            isPresented: $showArchiveConfirm,
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                store.archiveHabit(habit)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Delete \(habit.name)? This cannot be undone.",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                store.deleteHabit(habit)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var checkboxButton: some View {
        Button {
            do {
                let result: ToggleCompletionResult = try store.toggleCompletion(habit: habit, date: selectedDate)
                if result.isCompleted {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                onToggleResult(result)
            } catch {
                // Persistence failure — no UI spec; leave silent for this slice.
            }
        } label: {
            CircularCheckbox(
                isCompleted: isCompleted,
                accessibilityLabelText: isCompleted ? "Completed, \(habit.name)" : "Not completed, \(habit.name)"
            )
        }
        .buttonStyle(.plain)
    }

    private var rowLabel: some View {
        HStack(spacing: 12) {
            Text(habit.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .strikethrough(isCompleted, color: AppColor.textSecondary)
            Spacer(minLength: 0)
            if streakCount >= 1 {
                HStack(spacing: 4) {
                    EmojiGlyphView(text: "🔥", fontSize: 17)
                        .frame(width: 22, height: 22)
                        .accessibilityHidden(true)
                    Text("\(streakCount)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Streak \(streakUnitAccessibility)")
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var rowActions: some View {
        ShareLink(item: shareMessage, subject: Text(habit.name), message: Text(shareMessage)) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        Button {
            onRequestReorder()
        } label: {
            Label("Reorder", systemImage: "arrow.up.arrow.down")
        }

        Button {
            onEdit()
        } label: {
            Label("Edit", systemImage: "pencil")
        }

        Button(role: .destructive) {
            showArchiveConfirm = true
        } label: {
            Label("Archive", systemImage: "archivebox")
        }

        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
