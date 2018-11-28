//
//  NotificationItem.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

struct NotificationInfoKeys {
    static let NotificationId = "notificationservice.notificationid"
    static let NotificationExtraInfo = "notificationservice.notificationextrainfo"
}

func ==(lhs: NotificationItem, rhs: NotificationItem) -> Bool {
    return lhs.identifier == rhs.identifier
}

class NotificationItem: Hashable {
    var identifier: String = UUID().uuidString
    
    var applicationIconBadgeNumberAddition: Int = 0
    
    // The first time, the notification should be fired
    var fireDate: Date
    
    /**
     Optionally provide the timezone.
     Only needed if the time is assigned to a specific timezone, not the time of the day.
     */
    var timeZone: TimeZone? = nil
    
    var alertTitle: String
    var alertBody: String
    
    var category: NotificationCategory
    
    var extraInfo: [String: AnyObject]? = nil
    
    var hashValue: Int { return identifier.hashValue }
    
    init(with fireDate: Date, title: String, body: String, category: NotificationCategory) {
        self.fireDate = fireDate
        self.alertTitle = title
        self.alertBody = body
        self.category = category
    }
}
