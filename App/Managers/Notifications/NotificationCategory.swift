//
//  NotificationCategory.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UserNotifications
import Foundation

enum NotificationCategory {
    case debtNotification(transactionId: Int)
    case incomeNotification(incomeSourceId: Int)
    case expenseNotification(expenseCategoryId: Int)
    case keepAliveNotification
}

extension NotificationCategory {
    
    static var all: [NotificationCategory] {
        return [.debtNotification(transactionId: 0),
                .incomeNotification(incomeSourceId: 0),
                .expenseNotification(expenseCategoryId: 0),
                .keepAliveNotification]
    }
    
    var identifier: String {
        switch self {
        case .debtNotification:         return "DEBT_NOTIFICATION"
        case .incomeNotification:       return "INCOME_REMINDER_NOTIFICATION"
        case .expenseNotification:      return "EXPENSE_REMINDER_NOTIFICATION"
        case .keepAliveNotification:    return "KEEP_ALIVE_NOTIFICATION"
        }
    }
    
    var actions: [NotificationAction] {
        switch self {
        case .keepAliveNotification:    return []
        case .debtNotification,
             .incomeNotification,
             .expenseNotification:      return [.show,
                                                .snoozeHour,
                                                .snoozeDay,
                                                .snoozeWeek,
                                                .cancel]
        }
        
    }
    
    var notificationIdentifier: String {
        switch self {
        case .debtNotification(let transactionId):          return "\(identifier)_\(transactionId)"
        case .incomeNotification(let incomeSourceId):       return "\(identifier)_\(incomeSourceId)"
        case .expenseNotification(let expenseCategoryId):   return "\(identifier)_\(expenseCategoryId)"
        case .keepAliveNotification:                        return identifier
        }
    }
    
    func destinationViewController(with action: NotificationAction?) -> Infrastructure.ViewController? {
        if let action = action, action == NotificationAction.cancel {
            return nil
        }
        
        //        switch self {
        //        case .approvedTradeNotification(let tradeTransactionId),
        //             .trackingNumberNotification(let tradeTransactionId),
        //             .trackingStatusNotification(let tradeTransactionId):
        //            return ViewController.TradeExchangeViewController(tradeTransactionId: tradeTransactionId)
        //        case .potentialTradesNotification, .keepAliveNotification:
        //            return ViewController.ItemExchangesGroupsViewController
        //        case .modifiedItemNotification(let itemId):
        //            return ViewController.ItemDetailsViewController(itemId: itemId)
        //        }
        return nil
    }
    
    static func category(by identifier: String?, with userInfo: [AnyHashable: Any]?) -> NotificationCategory? {
        guard let identifier = identifier else { return nil }
        switch identifier {
        case "DEBT_NOTIFICATION":
            guard let transactionId = userInfo?["transaction_id"] as? Int else { return nil }
            return .debtNotification(transactionId: transactionId)
        case "INCOME_REMINDER_NOTIFICATION":
            guard let incomeSourceId = userInfo?["income_source_id"] as? Int else { return nil }
            return .incomeNotification(incomeSourceId: incomeSourceId)
        case "EXPENSE_REMINDER_NOTIFICATION":
            guard let expenseCategoryId = userInfo?["expense_category_id"] as? Int else { return nil }
            return .expenseNotification(expenseCategoryId: expenseCategoryId)
        case "KEEP_ALIVE_NOTIFICATION":
            return .keepAliveNotification
        default:
            return nil
        }
    }
    
    func toUNNotificationCategory() -> UNNotificationCategory {
        return UNNotificationCategory(identifier: identifier,
                                      actions: actions.map { $0.toUNNotificationAction() },
                                      intentIdentifiers: [])
    }
}
