//
//  NotificationScheduler.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import UserNotifications

struct NotificationScheduler {
    /// Schedules a notification with the provided parameters
    /// - Parameters:
    ///   - title: Title of the notification
    ///   - subtitle: Subtitle of the notification
    ///   - body: Body text of the notification
    ///   - hour: The hour to schedule the notification (24-hour format)
    ///   - minute: The minute to schedule the notification
    static func scheduleNotification(title: String, subtitle: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(UUID().uuidString)-Notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(hour):\(minute).")
            }
        }
    }
}
