//
//  NotificationsManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol NotificationsManagerProtocol {
    var systemNotificationsEnabled: Promise<Bool> { get }
    
    func enableNotifications()
    func disableNotifications()
    func rescheduleKeepAliveNotifications()
    func cancelKeepAliveNotifications()
    func cancelAllSceduledNotifications()
    func scheduleNotification(with item: NotificationItem) throws
}
