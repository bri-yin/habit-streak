//
//  NotificationService.swift
//  habit-streak
//
//  PRD §5.7 — local reminders per habit; PRD §5.6 — master toggle from Settings.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared: NotificationService = NotificationService()

    private init() {}

    private static let masterNotificationsEnabledKey: String = "masterNotificationsEnabled"

    var masterNotificationsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: Self.masterNotificationsEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Self.masterNotificationsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.masterNotificationsEnabledKey)
        }
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        let settings: UNNotificationSettings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func cancelReminder(for habit: Habit) {
        let id: String = habit.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// PRD §5.7 — schedule or cancel daily calendar trigger for this habit.
    func syncReminder(for habit: Habit) {
        Task { await scheduleReminderIfNeeded(habit: habit) }
    }

    private func scheduleReminderIfNeeded(habit: Habit) async {
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        let id: String = habit.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard masterNotificationsEnabled else { return }
        guard habit.reminderEnabled, habit.archivedAt == nil else { return }
        guard let hour: Int = habit.reminderHour, let minute: Int = habit.reminderMinute else { return }

        let settings: UNNotificationSettings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        default:
            return
        }

        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "\(habit.name) \(habit.emoji)"
        content.body = "Time for your daily habit. Keep the streak going!"

        var dateComponents: DateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request: UNNotificationRequest = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { _ in }
    }

    /// Re-schedule all habits (e.g. after master toggle).
    func rescheduleAllActiveReminders(habits: [Habit]) {
        for habit in habits where habit.archivedAt == nil {
            syncReminder(for: habit)
        }
    }
}
