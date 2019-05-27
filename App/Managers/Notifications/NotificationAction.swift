//
//  NotificationAction.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UserNotifications
import UIKit
import SwiftDate

enum NotificationAction: String {
    case show = "show"
    case cancel = "cancel"
    case snoozeHour = "snooze_hour"
    case snoozeDay = "snooze_day"
    case snoozeWeek = "snooze_week"
    
    // The identifier that you use internally to handle the action.
    var identifier: String {
        return self.rawValue
    }
    
    // The localized title of the action button.
    var title: String {
        switch self {
        case .show: return "Открыть"
        case .cancel: return "Отмена"
        case .snoozeHour: return "Напомнить через час"
        case .snoozeDay: return "Напомнить через день"
        case .snoozeWeek: return "Напомнить через неделю"
        }
    }
    
    var options: UNNotificationActionOptions {
        switch self {
        case .show: return [.foreground, .authenticationRequired]
        default:    return []
        }
    }
        
    var snoozeTill: Date? {
        switch self {
        case .show,
             .cancel:       return nil
        case .snoozeHour:   return Date() + 1.hours
        case .snoozeDay:    return Date() + 1.days
        case .snoozeWeek:   return Date() + 1.weeks
        }
    }
    
    func toUNNotificationAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: identifier,
                                    title: title,
                                    options: options)
    }
}
