//
//  NotificationAction.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UserNotifications
import UIKit

enum NotificationAction: String {
    case show = "show", cancel = "cancel"
    
    // The localized title of the action button.
    var title: String {
        switch self {
        case .show: return "Show"
        case .cancel: return "Cancel"
        }
    }
    
    @available(iOS 10.0, *)
    var options: UNNotificationActionOptions {
        switch self {
        case .show: return [.foreground, .authenticationRequired]
        case .cancel: return []
        }
    }
    
    // Destructive actions are highlighted appropriately to indicate their nature.
    var isDestructive: Bool {
        switch self {
        default: return false
        }
    }
}

// MARK: - Helper Extensions

extension NotificationAction {
    
    // The identifier that you use internally to handle the action.
    var identifier: String {
        return self.rawValue
    }
    
    // Specifies whether the app must be in the foreground to perform the action.
    var activationMode: UIUserNotificationActivationMode {
        switch self {
        case .show: return .foreground
        default: return .background
        }
    }
    
    // Indicates whether user authentication is required to perform the action.
    var authenticationRequired: Bool {
        switch self {
        case .show: return true
        default: return false
        }
    }
}

extension UIMutableUserNotificationAction {
    convenience init(notificationAction: NotificationAction) {
        self.init()
        
        self.identifier = notificationAction.identifier
        self.title = notificationAction.title
        self.activationMode = notificationAction.activationMode
        self.isDestructive = notificationAction.isDestructive
        self.isAuthenticationRequired = notificationAction.authenticationRequired
    }
}
