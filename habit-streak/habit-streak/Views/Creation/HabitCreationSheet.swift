//
//  HabitCreationSheet.swift
//  habit-streak
//
//  PRD §5.2 — create and edit habit (same sheet); validation; reminder time (PRD §5.7 wired later).
//

import SwiftData
import SwiftUI

/// Values passed from the habit library (PRD §5.3) to pre-fill the creation sheet.
struct HabitCreationPrefill: Equatable {
    var name: String
    var emoji: String
    var frequency: FrequencyMode
    var weekdays: Set<WeekDay>
    var countPerPeriod: Int

    init(
        name: String,
        emoji: String,
        frequency: FrequencyMode = .daily,
        weekdays: Set<WeekDay> = Set(WeekDay.allCases),
        countPerPeriod: Int = 1
    ) {
        self.name = name
        self.emoji = emoji
        self.frequency = frequency
        self.weekdays = weekdays
        self.countPerPeriod = countPerPeriod
    }
}

struct HabitEditorConfig: Identifiable {
    let id: UUID
    var existing: Habit?
    var prefill: HabitCreationPrefill?

    init(existing: Habit?, prefill: HabitCreationPrefill?) {
        self.id = existing?.id ?? UUID()
        self.existing = existing
        self.prefill = prefill
    }
}

struct HabitCreationSheet: View {
    @Environment(HabitStore.self) private var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    var existing: Habit?
    var prefill: HabitCreationPrefill?
    var onFinished: () -> Void

    @State private var name: String = ""
    @State private var emoji: String = "⭐️"
    @State private var frequency: FrequencyMode = .daily
    @State private var selectedWeekdays: Set<WeekDay> = Set(WeekDay.allCases)
    @State private var countPerPeriod: Int = 1
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = HabitCreationSheet.defaultRoundedReminderTime()
    @State private var showEmojiPicker: Bool = false
    @State private var didApplyInitialPayload: Bool = false

    private var isEditMode: Bool {
        existing != nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && (!selectedWeekdays.isEmpty || frequency != .daily)
    }

    private var weekdaySummary: String {
        let order: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return order
            .filter { selectedWeekdays.contains($0) }
            .map(\.longName)
            .joined(separator: ", ")
    }

    private var countRange: ClosedRange<Int> {
        switch frequency {
        case .daily:
            return 1...1
        case .weekly:
            return 1...7
        case .monthly:
            return 1...999
        }
    }

    private var countLabel: String {
        switch frequency {
        case .daily:
            return ""
        case .weekly:
            return "Per week"
        case .monthly:
            return "Per month"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColor.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        nameRow

                        FrequencySegmentedControl(selection: $frequency)
                            .onChange(of: frequency) { _, newValue in
                                clampCountForFrequency(newValue)
                            }

                        if frequency == .daily {
                            Text(weekdaySummary)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(AppColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            WeekdayPickerView(selectedWeekdays: $selectedWeekdays)
                        }

                        if frequency == .weekly {
                            CounterStepperView(label: "Times per week", value: $countPerPeriod, range: 1...7)
                        }

                        if frequency == .monthly {
                            CounterStepperView(label: "Times per month", value: $countPerPeriod, range: 1...999)
                        }

                        reminderSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                footerButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .background(
                        LinearGradient(
                            colors: [AppColor.bgPrimary.opacity(0), AppColor.bgPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false)
                    )
            }
            .navigationTitle(isEditMode ? "Edit habit" : "New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onFinished()
                        dismiss()
                    }
                    .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
        .onAppear {
            applyInitialPayloadIfNeeded()
        }
        .onChange(of: reminderEnabled) { _, isOn in
            if isOn {
                Task {
                    _ = await NotificationService.shared.requestAuthorizationIfNeeded()
                }
            }
        }
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(selectedEmoji: $emoji)
                .presentationDetents([.medium, .large])
        }
    }

    private var nameRow: some View {
        HStack(alignment: .center, spacing: 12) {
            TextField("Habit name", text: $name)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .textFieldStyle(.plain)
                .accessibilityLabel("Habit name")

            Button {
                showEmojiPicker = true
            } label: {
                EmojiGlyphView(text: emojiDisplay, fontSize: 28)
                    .frame(width: 52, height: 52)
                    .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.bgTertiary))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose emoji")
        }
    }

    private var emojiDisplay: String {
        let t = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "⭐️" : t
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Reminder", isOn: $reminderEnabled)
                .font(.system(size: 17, weight: .regular))
                .tint(AppColor.accentGreen)
                .foregroundStyle(AppColor.textPrimary)
                .accessibilityLabel("Reminder")

            if reminderEnabled {
                DatePicker(
                    "Reminder time",
                    selection: $reminderTime,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AppColor.accentBlue)
                .accessibilityLabel("Reminder time")
            }
        }
    }

    private var footerButton: some View {
        Button {
            Task { await submitAsync() }
        } label: {
            Text(isEditMode ? "Save changes" : "Create habit")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .liquidGlass(in: Capsule(), interactive: true, tint: AppColor.accentBlue, fallback: AppColor.accentBlue)
        }
        .buttonStyle(.plain)
        .disabled(!isValid)
        .opacity(isValid ? 1 : 0.45)
        .accessibilityLabel(isEditMode ? "Save changes" : "Create habit")
    }

    private func applyInitialPayloadIfNeeded() {
        guard !didApplyInitialPayload else { return }
        didApplyInitialPayload = true
        if let habit = existing {
            name = habit.name
            emoji = habit.emoji
            frequency = habit.frequency
            selectedWeekdays = Set(habit.weekdays)
            countPerPeriod = max(1, habit.countPerPeriod)
            reminderEnabled = habit.reminderEnabled
            if let h = habit.reminderHour, let m = habit.reminderMinute {
                reminderTime = Self.timeFrom(hour: h, minute: m)
            } else {
                reminderTime = Self.defaultRoundedReminderTime()
            }
        } else if let p = prefill {
            name = p.name
            emoji = p.emoji
            frequency = p.frequency
            selectedWeekdays = p.weekdays
            countPerPeriod = max(1, p.countPerPeriod)
            reminderEnabled = false
            reminderTime = Self.defaultRoundedReminderTime()
        }
        clampCountForFrequency(frequency)
    }

    private func clampCountForFrequency(_ mode: FrequencyMode) {
        switch mode {
        case .daily:
            countPerPeriod = 1
        case .weekly:
            countPerPeriod = min(max(1, countPerPeriod), 7)
        case .monthly:
            countPerPeriod = min(max(1, countPerPeriod), 999)
        }
    }

    @MainActor
    private func submitAsync() async {
        guard isValid else { return }
        if reminderEnabled {
            _ = await NotificationService.shared.requestAuthorizationIfNeeded()
        }
        let cal: Calendar = Calendar.current
        let timeComps: DateComponents = cal.dateComponents([.hour, .minute], from: reminderTime)

        if let habit = existing {
            habit.name = trimmedName
            habit.emoji = emojiDisplay
            habit.frequency = frequency
            habit.weekdays = Array(selectedWeekdays).sorted { $0.rawValue < $1.rawValue }
            habit.countPerPeriod = countPerPeriod
            habit.reminderEnabled = reminderEnabled
            habit.reminderHour = reminderEnabled ? timeComps.hour : nil
            habit.reminderMinute = reminderEnabled ? timeComps.minute : nil
            store.updateHabit(habit)
            NotificationService.shared.syncReminder(for: habit)
        } else {
            let habit = Habit(name: trimmedName, emoji: emojiDisplay, frequency: frequency)
            habit.weekdays = Array(selectedWeekdays).sorted { $0.rawValue < $1.rawValue }
            habit.countPerPeriod = countPerPeriod
            habit.reminderEnabled = reminderEnabled
            habit.reminderHour = reminderEnabled ? timeComps.hour : nil
            habit.reminderMinute = reminderEnabled ? timeComps.minute : nil
            habit.order = (try? store.nextHabitOrder()) ?? 0
            store.addHabit(habit)
            NotificationService.shared.syncReminder(for: habit)
        }
        onFinished()
        dismiss()
    }

    private static func defaultRoundedReminderTime() -> Date {
        let cal: Calendar = Calendar.current
        let now: Date = Date()
        let n: Int = cal.component(.minute, from: now)
        let rounded: Int = ((n + 2) / 5) * 5
        var h: Int = cal.component(.hour, from: now)
        var m: Int = rounded
        if m >= 60 {
            m = 0
            h = (h + 1) % 24
        }
        var comps: DateComponents = DateComponents()
        comps.hour = h
        comps.minute = m
        return cal.date(from: comps) ?? now
    }

    private static func timeFrom(hour: Int, minute: Int) -> Date {
        var comps: DateComponents = DateComponents()
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }
}

private extension WeekDay {
    var longName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
