//
//  KeepAliveNotificationItem.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import SwiftDate

class KeepAliveNotificationItem: NotificationItem {
    
    private static let notificationIdPrefix: String = String(describing: KeepAliveNotificationItem.self)
    
    init(apart date: Date, with numberOfDaysBetween: Int, and notificationNumber: Int, messageNumber: Int) {
        let keepaliveTitle = ""
        let keepaliveBody = NSLocalizedString("KEEP_ALIVE_NOTIFICATION_\(messageNumber)", comment: "")
        let fireDate = date + (numberOfDaysBetween * notificationNumber).days
//        let fireDate = Date() + (numberOfDaysBetween * notificationNumber * 10).seconds
        super.init(with: fireDate, title: keepaliveTitle, body: keepaliveBody, category: .keepAliveNotification)
        self.identifier = KeepAliveNotificationItem.notificationId(with: notificationNumber)
    }
    
    static func notificationId(with number: Int) -> String {
        return "\(KeepAliveNotificationItem.notificationIdPrefix)-\(number)"
    }
}
