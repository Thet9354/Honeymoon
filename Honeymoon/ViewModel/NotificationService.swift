//
//  NotificationService.swift
//  Honeymoon
//
//  Retention: schedules on-device countdown nudges for a trip's travel date
//  (90 / 60 / 30 / 7 / 1 days before). Uses local notifications only — no APNs,
//  no server, no paid program required — so it works immediately, including in
//  the simulator. Remote push can layer on later.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    /// Days-before milestones and their copy. `%@` is the destination name.
    private static let milestones: [(days: Int, title: String, body: String)] = [
        (90, "90 days to your honeymoon 🌴", "Time to book flights to %@ while fares are kind."),
        (60, "60 days to %@ ✈️", "Lock in your stay and the big bookings now."),
        (30, "One month until %@ 💍", "Finalise experiences and start your packing list."),
        (7,  "One week to go!", "Check passports and currency, and confirm your %@ bookings."),
        (1,  "Tomorrow! 🥂", "Your %@ honeymoon begins. Bon voyage!")
    ]

    /// Requests permission if undetermined; returns whether we're allowed to post.
    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    /// Schedules (or reschedules) the countdown for one trip. Clears any previous
    /// reminders for the same destination first, and skips milestones in the past.
    func scheduleCountdown(destinationId: String, place: String, startDate: Date) async {
        cancel(destinationId: destinationId)
        guard await requestAuthorizationIfNeeded() else { return }

        let calendar = Calendar.current
        for milestone in Self.milestones {
            guard let dayBefore = calendar.date(byAdding: .day, value: -milestone.days, to: startDate) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: dayBefore)
            components.hour = 9 // 9am local
            guard let fireDate = calendar.date(from: components), fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = String(format: milestone.title, place)
            content.body = String(format: milestone.body, place)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour], from: fireDate),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: Self.identifier(destinationId, milestone.days),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// Removes pending reminders for one trip.
    func cancel(destinationId: String) {
        let ids = Self.milestones.map { Self.identifier(destinationId, $0.days) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Removes all pending reminders (used when the user turns reminders off).
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    private static func identifier(_ destinationId: String, _ days: Int) -> String {
        "trip-\(destinationId)-\(days)"
    }
}
