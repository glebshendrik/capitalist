//
//  KeepAliveNotificationItem.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import SwiftDate

class KeepAliveNotificationItem: NotificationItem {
    
    fileprivate static let notificationIdPrefix: String = String(describing: KeepAliveNotificationItem.self)
    
    init(apart date: Date, with numberOfDaysBetween: Int, and notificationNumber: Int) {
        let keepaliveTitle = "Hey There!"
        let keepaliveBody = "Seems like you haven't opened the app for a while"
        let fireDate = date + (numberOfDaysBetween * notificationNumber).days
        super.init(with: fireDate, title: keepaliveTitle, body: keepaliveBody, category: .keepAliveNotification)
        self.identifier = KeepAliveNotificationItem.notificationId(with: notificationNumber)
    }
    
    static func notificationId(with number: Int) -> String {
        return "\(KeepAliveNotificationItem.notificationIdPrefix)-\(number)"
    }
}
