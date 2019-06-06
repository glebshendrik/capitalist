//
//  NotificationsManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftDate
import PromiseKit
import SwifterSwift

enum NotificationsManagerError: Error {
    case notificationsAreNotAllowed
    case notificationsAlreadyEnabled
    case schedulingNotificationsInThePastNotAllowed
}

@available(iOS 10.0, *)
class NotificationsManager: NSObject, NotificationsManagerProtocol {
    private static let maxNumberOfKeepAliveNotifications: Int = 5
    private static let numberOfDaysBetweenKeepAliveNotifications: Int = 3
    private static let numberOfKeepAliveNotificationMessages: Int = 11
    private let notificationsHandler: NotificationsHandlerProtocol
    private let userDefaults = UserDefaults.standard
    let defaultOtherNotificationsFireTime: Date = Date().dateAt(.startOfDay) + 12.hours
    
    private var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    private var notificationsSettings: Promise<UNNotificationSettings> {
        return Promise { notificationCenter.getNotificationSettings(completionHandler: $0.fulfill) }
    }
    
    var systemNotificationsEnabled: Promise<Bool> {
        return notificationsSettings.map { $0.authorizationStatus == .authorized }
    }
    
    init(notificationsHandler: NotificationsHandlerProtocol) {
        self.notificationsHandler = notificationsHandler
    }
    
    func enableNotifications() {
        registerForNotifications(inApplication: UIApplication.shared)
    }
    
    func disableNotifications() {
        unregisterForNotifications(inApplication: UIApplication.shared)
    }
    
    func scheduleNotification(with item: NotificationItem) throws {
        
        let content = UNMutableNotificationContent()
        content.title = item.alertTitle
        content.body = item.alertBody
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = item.category.identifier
        content.badge = NSNumber(value: (content.badge ?? 0).intValue + item.applicationIconBadgeNumberAddition)
        
        return try scheduleNotification(with: item.identifier, date: item.fireDate, content: content)
    }
    
    func rescheduleKeepAliveNotifications() {
        cancelKeepAliveNotifications()
        
        _ = systemNotificationsEnabled.done { systemNotificationsEnabled in
            
            guard systemNotificationsEnabled else { return }
            
            self.scheduleKeepAliveNotifications(startingFrom: self.defaultOtherNotificationsFireTime)
        }
    }
    
    func cancelKeepAliveNotifications() {
        for number in 1...NotificationsManager.maxNumberOfKeepAliveNotifications {
            let identifier = KeepAliveNotificationItem.notificationId(with: number)
            cancelScheduledNotification(with: identifier)
        }
    }
    
    func cancelAllSceduledNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        UIApplication.cleanupBadgeNumber()
    }
    
    private func registerForNotifications(inApplication application: UIApplication) {
        
        notificationCenter.delegate = self
        
        let categories = Set<UNNotificationCategory>(NotificationCategory.all.map { $0.toUNNotificationCategory() })
        
        notificationCenter.setNotificationCategories(categories)
        
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func unregisterForNotifications(inApplication application: UIApplication) {
        application.unregisterForRemoteNotifications()
    }
    
    private func scheduleKeepAliveNotifications(startingFrom date: Date) {
        let messageNumbers: [Int] = Array(1...NotificationsManager.numberOfKeepAliveNotificationMessages).shuffled()
        for number in 1...NotificationsManager.maxNumberOfKeepAliveNotifications {
            let keepAliveNotificationItem = KeepAliveNotificationItem(apart: date,
                                                                      with: NotificationsManager.numberOfDaysBetweenKeepAliveNotifications,
                                                                      and: number,
                                                                      messageNumber: messageNumbers[number])
            try? scheduleNotification(with: keepAliveNotificationItem)
        }
    }
    
    private func scheduleNotification(with identifier: String, date: Date, content: UNNotificationContent) throws {
        
        guard date > Date() else {
            throw NotificationsManagerError.schedulingNotificationsInThePastNotAllowed
        }
        
        // Allow only one notification to be present with an id (delete the others)
        cancelScheduledNotification(with: identifier)
        
        let notificationRequest = createNotificationRequest(identifier: identifier, date: date, content: content)
        notificationCenter.add(notificationRequest)
        
        print("[NOTI] Added scheduled notification with id: \(identifier), date: \(date)")
    }
        
    private func createNotificationRequest(identifier: String, date: Date, content: UNNotificationContent) -> UNNotificationRequest {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    private func cancelScheduledNotification(with identifier: String) {
        
        _ = scheduledNotificationsIdentifiers().done { identifiers in
            for notificationId in identifiers {
                if notificationId == identifier {
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    print("[NOTI] Cancelled scheduled notification with id: \(identifier)")
                }
            }
        }
    }
    
    private func scheduledNotificationsIdentifiers() -> Promise<[String]> {
        return Promise<[String]> { seal in
            notificationCenter.getPendingNotificationRequests { requests in
                seal.fulfill(requests.compactMap { $0.identifier })
            }
        }
    }
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // When received notification in Foreground
        // Just show default alert
        completionHandler([[.alert, .badge]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        handleNotification(actionId: response.actionIdentifier,
                           content: response.notification.request.content,
                           applicationStateWhenReceivedNotification: UIApplication.shared.applicationState)
        completionHandler()
    }
}

extension NotificationsManager {
    
    private func handleNotification(actionId: String,
                                    content: UNNotificationContent,
                                    applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        let category = NotificationCategory.category(by: content.categoryIdentifier,
                                                     with: content.userInfo)
        let action = NotificationAction(rawValue: actionId)
        
        handleSnooze(category: category, action: action, content: content)
        
        notificationsHandler.handleNotification(category: category,
                                                action: action,
                                                applicationStateWhenReceivedNotification: state)
    }
    
    private func handleSnooze(category: NotificationCategory?,
                              action: NotificationAction?,
                              content: UNNotificationContent) {
        guard let action = action,
            let snoozeTill = action.snoozeTill,
            let category = category else { return }
        
        try? scheduleNotification(with: category.notificationIdentifier, date: snoozeTill, content: content)
    }
}
