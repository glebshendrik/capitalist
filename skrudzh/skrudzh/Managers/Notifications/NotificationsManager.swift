//
//  NotificationsManager.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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

class NotificationsManager: NSObject, NotificationsManagerProtocol {
    fileprivate static let maxNumberOfKeepAliveNotifications: Int = 5
    fileprivate static let numberOfDaysBetweenKeepAliveNotifications: Int = 3
    fileprivate let notificationsHandler: NotificationsHandlerProtocol
    fileprivate let userDefaults = UserDefaults.standard
    let defaultOtherNotificationsFireTime: Date
    
    @available(iOS 10.0, *)
    fileprivate var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    fileprivate var scheduledLocalNotifications: [UILocalNotification] {
        return UIApplication.shared.scheduledLocalNotifications ?? []
    }
    
    var systemNotificationsEnabled: Promise<Bool> {
        if #available(iOS 10.0, *) {
            return Promise { fulfill, reject in
                notificationCenter.getNotificationSettings { settings in
                    fulfill(settings.authorizationStatus == .authorized)
                }
            }
        } else {
            guard let settings = UIApplication.shared.currentUserNotificationSettings else { return Promise(value: false) }
            return Promise(value: settings.types.contains(.alert) || settings.types.contains(.sound) || settings.types.contains(.badge))
        }
    }
    
    init(notificationsHandler: NotificationsHandlerProtocol) {
        self.notificationsHandler = notificationsHandler
        defaultOtherNotificationsFireTime = Date().startOfDay + 9.hours
    }
    
    
    func enableNotifications() -> Promise<Void> {
        return systemNotificationsEnabled.then { systemEnabled -> Promise<Void> in
            guard !systemEnabled else {
                // even if notifications already enabled
                // register device token in case new user logged in
                UIApplication.shared.registerForRemoteNotifications()
                return Promise(error: NotificationsManagerError.notificationsAlreadyEnabled)
            }
            self.registerForNotifications(inApplication: UIApplication.shared)
            return Promise(value: ())
        }
    }
    
    func disableNotifications() -> Promise<Void> {
        unregisterForNotifications(inApplication: UIApplication.shared)
        return Promise(value: ())
    }
    
    func rescheduleKeepAliveNotifications() {
        cancelKeepAliveNotifications()
        
        _ = systemNotificationsEnabled.then { systemNotificationsEnabled -> Void in
            
            guard systemNotificationsEnabled else { return }
            do { try self.scheduleKeepAliveNotifications(startingFrom: self.defaultOtherNotificationsFireTime) } catch {}
        }
    }
    
    func cancelKeepAliveNotifications() {
        for number in 1...NotificationsManager.maxNumberOfKeepAliveNotifications {
            let identifier = KeepAliveNotificationItem.notificationId(with: number)
            cancelScheduledNotification(with: identifier)
        }
    }
    
    func cancelAllSceduledNotifications() {
        if #available(iOS 10.0, *) {
            notificationCenter.removeAllPendingNotificationRequests()
        }
        else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        UIApplication.cleanupBadgeNumber()
    }
    
    @available(iOS 10.0, *)
    private func registerForNotificationsIOS10(inApplication application: UIApplication) {
        notificationCenter.delegate = self
        
        let categories = Set<UNNotificationCategory>(NotificationCategory.allCategories().map { categoryType -> UNNotificationCategory in
            let actions = categoryType.actionsForDefaultContext.map { UNNotificationAction(identifier: $0.identifier, title: $0.title, options: $0.options) }
            
            // First create the category
            return UNNotificationCategory(identifier: categoryType.identifier, actions: actions, intentIdentifiers: [])
        })
        
        notificationCenter.setNotificationCategories(categories)
        
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    fileprivate func registerForNotificationsIOS9(inApplication application: UIApplication) {
        // Define the notification types
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        
        // Define the categories
        
        var categories = Set<UIUserNotificationCategory>()
        
        for categoryType in NotificationCategory.allCategories() {
            
            // First create the category
            let category = UIMutableUserNotificationCategory()
            
            // Identifier to include in your push payload and local notification
            category.identifier = categoryType.identifier
            
            // Set the actions to display in the default context
            category.setActions(
                categoryType.actionsForDefaultContext.map({UIMutableUserNotificationAction(notificationAction: $0)}),
                for: .default)
            
            // Set the actions to display in a minimal context
            category.setActions(
                categoryType.actionsForDefaultContext.map({UIMutableUserNotificationAction(notificationAction: $0)}),
                for: .minimal)
            
            // Add the category to the collection
            categories.insert(category)
            
        }
        
        // Create configuration from types & categories
        let settings = UIUserNotificationSettings(types: notificationTypes, categories: categories)
        
        // Register for notifications
        application.registerUserNotificationSettings(settings)
        // Register for remote notifications
        application.registerForRemoteNotifications()
    }
    
    fileprivate func registerForNotifications(inApplication application: UIApplication) {
        if #available(iOS 10.0, *) {
            registerForNotificationsIOS10(inApplication: UIApplication.shared)
        } else {
            registerForNotificationsIOS9(inApplication: UIApplication.shared)
        }
    }
    
    fileprivate func unregisterForNotifications(inApplication application: UIApplication) {
        application.unregisterForRemoteNotifications()
    }
    
    fileprivate func scheduleKeepAliveNotifications(startingFrom date: Date) throws {
        for number in 1...NotificationsManager.maxNumberOfKeepAliveNotifications {
            let keepAliveNotificationItem = KeepAliveNotificationItem(
                apart: date,
                with: NotificationsManager.numberOfDaysBetweenKeepAliveNotifications,
                and: number)
            try scheduleNotification(with: keepAliveNotificationItem)
        }
    }
    
    fileprivate func scheduleNotification(with item: NotificationItem) throws {
        
        guard item.fireDate > Date() else {
            throw NotificationsManagerError.schedulingNotificationsInThePastNotAllowed
        }
        
        // Allow only one notification to be present with an id (delete the others)
        cancelScheduledNotification(with: item.identifier)
        
        if #available(iOS 10.0, *) {
            let notificationRequest = createNotificationRequest(for: item)
            notificationCenter.add(notificationRequest)
        }
        else {
            let notification = createNotification(for: item)
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
        print("[NOTI] Added scheduled notification with id: \(item.identifier), date: \(item.fireDate)")
    }
    
    fileprivate func createNotification(for item: NotificationItem) -> UILocalNotification {
        let notification = UILocalNotification()
        
        notification.fireDate = item.fireDate
        notification.timeZone = item.timeZone
        
        notification.alertTitle = item.alertTitle
        
        notification.alertBody = item.alertBody
        notification.applicationIconBadgeNumber += item.applicationIconBadgeNumberAddition
        
        notification.category = item.category.identifier
        
        // Construct userInfo
        var userInfo: [String: Any] = [:]
        userInfo[NotificationInfoKeys.NotificationId] = item.identifier
        if let extraInfo = item.extraInfo {
            userInfo[NotificationInfoKeys.NotificationExtraInfo] = extraInfo
        }
        notification.userInfo = userInfo
        
        return notification
    }
    
    @available(iOS 10.0, *)
    fileprivate func createNotificationRequest(for item: NotificationItem) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = item.alertTitle
        content.body = item.alertBody
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = item.category.identifier
        content.badge = NSNumber(value: (content.badge ?? 0).intValue + item.applicationIconBadgeNumberAddition)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: item.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: false)
        return UNNotificationRequest(identifier: item.identifier, content: content, trigger: trigger)
    }
    
    fileprivate func cancelScheduledNotification(with identifier: String) {
        
        _ = scheduledNotificationsIdentifiers().then { identifiers -> Void in
            for notificationId in identifiers {
                if notificationId == identifier {
                    if #available(iOS 10.0, *) {
                        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                        print("[NOTI] Cancelled scheduled notification with id: \(identifier)")
                    }
                    else {
                        if let notification = (self.scheduledLocalNotifications.first { $0.identifier == identifier }) {
                            UIApplication.shared.cancelLocalNotification(notification)
                            print("[NOTI] Cancelled scheduled notification with id: \(identifier)")
                        }
                    }
                    return
                }
            }
        }
    }
    
    fileprivate func scheduledNotificationsIdentifiers() -> Promise<[String]> {
        if #available(iOS 10.0, *) {
            return Promise { fulfill, reject in
                notificationCenter.getPendingNotificationRequests { requests in
                    fulfill(requests.flatMap { $0.identifier })
                }
            }
        }
        else {
            return Promise(value: scheduledLocalNotifications.flatMap { $0.identifier })
        }
    }
}

@available(iOS 10.0, *)
extension NotificationsManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        notificationReceived(categoryId: notification.request.content.categoryIdentifier,
                             actionId: nil,
                             title: notification.request.content.title,
                             message: notification.request.content.body,
                             userInfo: notification.request.content.userInfo,
                             applicationStateWhenReceivedNotification: UIApplication.shared.applicationState)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        notificationReceived(categoryId: response.notification.request.content.categoryIdentifier,
                             actionId: response.actionIdentifier,
                             title: response.notification.request.content.title,
                             message: response.notification.request.content.body,
                             userInfo: response.notification.request.content.userInfo,
                             applicationStateWhenReceivedNotification: UIApplication.shared.applicationState)
        completionHandler()
    }
}

extension NotificationsManager {
    func application(_ application: UIApplication,
                     didReceive notification: UILocalNotification,
                     in state: UIApplication.State) {
        
        localNotificationReceived(notification: notification,
                                  applicationStateWhenReceivedNotification: state)
    }
    
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: @escaping () -> Void, applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        localNotificationReceived(notification: notification,
                                  actionId: identifier,
                                  applicationStateWhenReceivedNotification: state)
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void,
                     applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        remoteNotificationReceived(userInfo: userInfo,
                                   applicationStateWhenReceivedNotification: state)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forRemoteNotification userInfo: [AnyHashable: Any],
                     completionHandler: @escaping () -> Void,
                     applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        remoteNotificationReceived(userInfo: userInfo,
                                   actionId: identifier,
                                   applicationStateWhenReceivedNotification: state)
        completionHandler()
    }
    
    private func localNotificationReceived(notification: UILocalNotification,
                                           actionId: String? = nil,
                                           applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationReceived(categoryId: notification.category,
                             actionId: actionId,
                             title: notification.alertTitle,
                             message: notification.alertBody,
                             applicationStateWhenReceivedNotification: state)
    }
    
    private func remoteNotificationReceived(userInfo: [AnyHashable : Any],
                                            actionId: String? = nil,
                                            applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        let aps = userInfo["aps"] as? [String: AnyObject]
        
        let categoryId = (aps?["category"]) as? String
        
        var title: String?
        var message: String?
        
        // Get the simple alert text
        if let alert = aps?["alert"] as? String {
            message = alert
        } else if let alertDict = aps?["alert"] as? [String: AnyObject] {
            // If it is a dictionary try to load the title and body
            //   If they have localized title and body, try to localize it with the arguments
            
            if let titleInDict = alertDict["title"] as? String {
                title = titleInDict
            }
            
            if let messageInDict = alertDict["body"] as? String {
                message = messageInDict
            }
        }
        
        notificationReceived(categoryId: categoryId,
                             actionId: actionId,
                             title: title,
                             message: message,
                             userInfo: userInfo,
                             applicationStateWhenReceivedNotification: state)
    }
    
    fileprivate func notificationReceived(categoryId: String?,
                                          actionId: String?,
                                          title: String?,
                                          message: String?,
                                          userInfo: [AnyHashable : Any] = [:],
                                          applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationReceived(category: NotificationCategory.category(by: categoryId, with: userInfo),
                             action: NotificationAction(rawValue: actionId ?? ""),
                             title: title,
                             message: message,
                             applicationStateWhenReceivedNotification: state)
    }
    
    private func notificationReceived(category: NotificationCategory?,
                                      action: NotificationAction? = nil,
                                      title: String?,
                                      message: String?,
                                      applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationsHandler.handleNotification(category: category,
                                                action: action,
                                                title: title,
                                                message: message,
                                                applicationStateWhenReceivedNotification: state)
    }
}
