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
    case saltedgeNotification(expenseSourceId: Int?)
}

extension NotificationCategory {
    
    static var all: [NotificationCategory] {
        return [.debtNotification(transactionId: 0),
                .incomeNotification(incomeSourceId: 0),
                .expenseNotification(expenseCategoryId: 0),
                .keepAliveNotification,
                .saltedgeNotification(expenseSourceId: nil)]
    }
    
    var identifier: String {
        switch self {
            case .debtNotification:
                return "DEBT_NOTIFICATION"
            case .incomeNotification:
                return "INCOME_REMINDER_NOTIFICATION"
            case .expenseNotification:
                return "EXPENSE_REMINDER_NOTIFICATION"
            case .keepAliveNotification:
                return "KEEP_ALIVE_NOTIFICATION"
            case .saltedgeNotification:
                return "SALTEDGE"
        }
    }
    
    var actions: [NotificationAction] {
        switch self {
            case .keepAliveNotification:    return []
            case .saltedgeNotification:     return [.show,
                                                    .cancel]
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
            case .debtNotification(let transactionId):
                return "\(identifier)_\(transactionId)"
            case .incomeNotification(let incomeSourceId):
                return "\(identifier)_\(incomeSourceId)"
            case .expenseNotification(let expenseCategoryId):
                return "\(identifier)_\(expenseCategoryId)"
            case .keepAliveNotification:
                return identifier
            case .saltedgeNotification(let expenseSourceId):
                return "\(identifier)_\(expenseSourceId ?? 0)"
        }
    }
    
    func destinationViewController(with action: NotificationAction?) -> Infrastructure.ViewController? {
        if let action = action, action == NotificationAction.cancel {
            return nil
        }
        
        switch self {
            case .saltedgeNotification(let expenseSourceId):
                if expenseSourceId == nil {
                    return nil
                }
                return Infrastructure.ViewController.ExpenseSourceInfoViewController
            default:
                return nil
        }
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
            case "SALTEDGE":
                guard
                    let expenseSourceIds = userInfo?["expense_source_ids"] as? [Int]
                else {
                    return nil
                }
                return .saltedgeNotification(expenseSourceId: expenseSourceIds.first)
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
