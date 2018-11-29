//
//  NotificationsCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class NotificationsCoordinator : NotificationsCoordinatorProtocol {
    fileprivate let userSessionManager: UserSessionManagerProtocol
    fileprivate let devicesService: DevicesServiceProtocol
    fileprivate let notificationsManager: NotificationsManagerProtocol
    fileprivate let navigator: NavigatorProtocol
    
    init(userSessionManager: UserSessionManagerProtocol,
         devicesService: DevicesServiceProtocol,
         notificationsManager: NotificationsManagerProtocol,
         navigator: NavigatorProtocol) {
        self.userSessionManager = userSessionManager
        self.devicesService = devicesService
        self.notificationsManager = notificationsManager
        self.navigator = navigator
    }
    
    func register(deviceToken: Data) -> Promise<Void> {
        guard let currentUserId = userSessionManager.currentSession?.userId else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        return devicesService.register(deviceToken: deviceToken, userId: currentUserId)
    }
}

extension NotificationsCoordinator {
    var systemNotificationsEnabled: Promise<Bool> {
        return notificationsManager.systemNotificationsEnabled
    }
    
    func enableNotifications() -> Promise<Void> {
        return notificationsManager.enableNotifications()
    }
    func disableNotifications() -> Promise<Void> {
        return notificationsManager.disableNotifications()
    }
    
    func rescheduleKeepAliveNotifications() {
        notificationsManager.rescheduleKeepAliveNotifications()
    }
    
    func cancelKeepAliveNotifications() {
        notificationsManager.cancelKeepAliveNotifications()
    }
    
    func updateBadges() {
        navigator.updateBadges()
    }
    
    func cancelAllSceduledNotifications() {
        notificationsManager.cancelAllSceduledNotifications()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification, in state: UIApplication.State) {
        notificationsManager.application(application, didReceive: notification, in: state)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: @escaping () -> Void, applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationsManager.application(application, handleActionWithIdentifier: identifier, forLocalNotification: notification, completionHandler: completionHandler, applicationStateWhenReceivedNotification: state)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void, applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationsManager.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler, applicationStateWhenReceivedNotification: state)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void, applicationStateWhenReceivedNotification state: UIApplication.State) {
        
        notificationsManager.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler, applicationStateWhenReceivedNotification: state)
    }
}
