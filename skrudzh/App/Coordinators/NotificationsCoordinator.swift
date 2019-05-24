//
//  NotificationsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class NotificationsCoordinator : NotificationsCoordinatorProtocol {
    private let userSessionManager: UserSessionManagerProtocol
    private let devicesService: DevicesServiceProtocol
    private let notificationsManager: NotificationsManagerProtocol
    private let navigator: NavigatorProtocol
    
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
    
    func enableNotifications() {
        notificationsManager.enableNotifications()
    }
    func disableNotifications() {
        notificationsManager.disableNotifications()
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
    
    func scheduleNotification(with item: NotificationItem) throws {
        try notificationsManager.scheduleNotification(with: item)
    }
}
