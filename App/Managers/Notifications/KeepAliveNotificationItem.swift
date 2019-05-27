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
    
    fileprivate static let notificationIdPrefix: String = String(describing: KeepAliveNotificationItem.self)
    
    init(apart date: Date, with numberOfDaysBetween: Int, and notificationNumber: Int) {
        let keepaliveTitle = ""
        let keepaliveBody = "Вы давно не пользовались приложением. Не забудьте внести свои доходы и расходы"
        let fireDate = date + (numberOfDaysBetween * notificationNumber).days
        super.init(with: fireDate, title: keepaliveTitle, body: keepaliveBody, category: .keepAliveNotification)
        self.identifier = KeepAliveNotificationItem.notificationId(with: notificationNumber)
    }
    
    static func notificationId(with number: Int) -> String {
        return "\(KeepAliveNotificationItem.notificationIdPrefix)-\(number)"
    }
}
