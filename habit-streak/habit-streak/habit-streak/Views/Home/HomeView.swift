//
//  HomeView.swift
//  habit-streak
//
//  PRD §5.1 — home layout: toolbar, week strip, date label, habit list, FAB, toast.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(HabitStore.self) private var store: HabitStore

    @Query(filter: #Predicate<Habit> { habit in habit.archivedAt == nil }, sort: [SortDescriptor(\.order)])
    private var habits: [Habit]

    @State private var editMode: EditMode = .inactive
    @State private var showLibrarySheet: Bool = false
    @State private var showEditPlaceholder: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    /// PRD §5.1 — in-memory schedule filter.
    /// TODO: Revisit in-memory filter if habit count grows past 50 (predicate / indexed fetch).
    private var scheduledHabits: [Habit] {
        habits
            .filter { DateHelpers.isHabitScheduled($0, on: store.selectedDate) }
            .sorted { $0.order < $1.order }
    }

    private var dateLabelText: String {
        let cal: Calendar = Calendar.current
        let todayStart: Date = cal.startOfDay(for: Date())
        if cal.isDate(store.selectedDate, inSameDayAs: todayStart) {
            return "Today"
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: store.selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColor.bgPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    WeekCalendarView()
                        .padding(.top, 8)

                    Text(dateLabelText)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    if habits.isEmpty {
                        emptyState
                    } else {
                        habitList
                    }
                }

                FloatingActionButton(accessibilityLabelText: "Open habit library") {
                    showLibrarySheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)

                if showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastMessage)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showToast)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        Text("Settings")
                            .foregroundStyle(AppColor.textPrimary)
                            .navigationTitle("Settings")
                            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .principal) {
                    Text("Habit Streak")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if editMode.isEditing {
                        EditButton()
                            .foregroundStyle(AppColor.textPrimary)
                    } else {
                        Color.clear.frame(width: 28, height: 28)
                    }
                }
            }
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showLibrarySheet) {
            Text("Habit Library")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding()
                .presentationDetents([.large])
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showLibrarySheet = false }
                    }
                }
        }
        .sheet(isPresented: $showEditPlaceholder) {
            Text("Edit habit (PRD §5.2)")
                .foregroundStyle(AppColor.textPrimary)
                .padding()
                .presentationDetents([.large])
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showEditPlaceholder = false }
                    }
                }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Text("No habits yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
            Text("Tap + to add a habit from the library.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var habitList: some View {
        List {
            ForEach(scheduledHabits, id: \.id) { habit in
                HabitRowView(
                    habit: habit,
                    selectedDate: store.selectedDate,
                    store: store,
                    onToggleResult: handleToggleResult,
                    onRequestReorder: {
                        withAnimation {
                            editMode = .active
                        }
                    },
                    onEdit: { showEditPlaceholder = true }
                )
            }
            .onMove { source, destination in
                var copy: [Habit] = scheduledHabits
                copy.move(fromOffsets: source, toOffset: destination)
                try? store.reorderHabits(afterMoving: copy)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 56)
    }

    private func handleToggleResult(_ result: ToggleCompletionResult) {
        if result.isFirstCompletionOfCalendarDay {
            toastMessage = "First day of a long streak! Well done!"
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

private extension EditMode {
    var isEditing: Bool {
        self == .active
    }
}
