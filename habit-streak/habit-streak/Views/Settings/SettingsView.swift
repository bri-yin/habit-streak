//
//  SettingsView.swift
//  habit-streak
//
//  PRD §5.6 — preferences, archived habits, data, about.
//

import SwiftData
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(HabitStore.self) private var store: HabitStore
    @Environment(\.openURL) private var openURL

    @State private var showClearConfirm: Bool = false
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var showDeniedAlert: Bool = false
    @State private var notificationsEnabled: Bool = true

    private var appVersion: String {
        let v: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        ZStack {
            AppColor.bgPrimary.ignoresSafeArea()
            List {
                Section {
                    Picker("Week starts on", selection: Binding(
                        get: { store.weekStartsOn },
                        set: { store.saveWeekStartsOnPreference($0) }
                    )) {
                        Text("Sunday").tag(WeekStartDay.sunday)
                        Text("Monday").tag(WeekStartDay.monday)
                        Text("Tuesday").tag(WeekStartDay.tuesday)
                        Text("Wednesday").tag(WeekStartDay.wednesday)
                        Text("Thursday").tag(WeekStartDay.thursday)
                        Text("Friday").tag(WeekStartDay.friday)
                        Text("Saturday").tag(WeekStartDay.saturday)
                    }
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary)
                    .accessibilityLabel("Week starts on")

                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .font(.system(size: 17, weight: .regular))
                        .tint(AppColor.accentGreen)
                        .foregroundStyle(AppColor.textPrimary)
                        .accessibilityLabel("Notifications master toggle")
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                Task { @MainActor in
                                    let ok: Bool = await NotificationService.shared.requestAuthorizationIfNeeded()
                                    if ok {
                                        NotificationService.shared.masterNotificationsEnabled = true
                                        try? store.rescheduleAllRemindersForActiveHabits()
                                    } else {
                                        notificationsEnabled = false
                                        showDeniedAlert = true
                                    }
                                }
                            } else {
                                NotificationService.shared.masterNotificationsEnabled = false
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }

                    Button("Open system notification settings") {
                        if let url: URL = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppColor.accentBlue)
                } header: {
                    Text("Preferences")
                        .foregroundStyle(AppColor.textSecondary)
                }
                .listRowBackground(AppColor.bgSecondary)

                Section {
                    NavigationLink {
                        ArchivedHabitsView()
                            .environment(store)
                    } label: {
                        Text("Archived habits")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .accessibilityLabel("Archived habits")
                } header: {
                    Text("Archive")
                        .foregroundStyle(AppColor.textSecondary)
                }
                .listRowBackground(AppColor.bgSecondary)

                Section {
                    if let url: URL = exportURL {
                        ShareLink(item: url, subject: Text("Habit Streak export")) {
                            Label("Export data", systemImage: "square.and.arrow.up")
                        }
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(AppColor.textPrimary)
                    } else {
                        Button("Prepare export") {
                            prepareExport()
                        }
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(AppColor.textPrimary)
                    }

                    Button("Clear all data", role: .destructive) {
                        showClearConfirm = true
                    }
                    .font(.system(size: 17, weight: .regular))
                } header: {
                    Text("Data")
                        .foregroundStyle(AppColor.textSecondary)
                }
                .listRowBackground(AppColor.bgSecondary)

                Section {
                    LabeledContent("Version", value: appVersion)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(AppColor.textPrimary)
                    Link("Source code", destination: URL(string: "https://github.com/")!)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(AppColor.accentBlue)
                } header: {
                    Text("About")
                        .foregroundStyle(AppColor.textSecondary)
                }
                .listRowBackground(AppColor.bgSecondary)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
        .onAppear {
            notificationsEnabled = NotificationService.shared.masterNotificationsEnabled
        }
        .confirmationDialog(
            "Clear all data? This cannot be undone.",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                try? store.clearAllData()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Notifications are off", isPresented: $showDeniedAlert) {
            Button("Open Settings") {
                if let url: URL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive habit reminders.")
        }
        .alert("Export failed", isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportError ?? "")
        }
    }

    private func prepareExport() {
        do {
            let data: Data = try store.exportJSON()
            let dir: URL = FileManager.default.temporaryDirectory
            let url: URL = dir.appendingPathComponent("habit-streak-export.json")
            try data.write(to: url, options: .atomic)
            exportURL = url
        } catch {
            exportError = error.localizedDescription
        }
    }
}
