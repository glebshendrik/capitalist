//
//  NotificationCategory.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

enum NotificationCategory {
    case potentialTradesNotification
    case approvedTradeNotification(tradeTransactionId: Int)
    case trackingNumberNotification(tradeTransactionId: Int)
    case trackingStatusNotification(tradeTransactionId: Int)
    
    case modifiedItemNotification(itemId: Int)
    case keepAliveNotification
}

extension NotificationCategory {
    
    static func allCategories() -> [NotificationCategory] {
        return [.potentialTradesNotification,
                .approvedTradeNotification(tradeTransactionId: 0),
                .trackingNumberNotification(tradeTransactionId: 0),
                .trackingStatusNotification(tradeTransactionId: 0),
                .modifiedItemNotification(itemId: 0),
                .keepAliveNotification]
    }
    
    // Identifier to include in your push payload and local notification
    var identifier: String {
        switch self {
        case .potentialTradesNotification:
            return "POTENTIAL_TRADES_NOTIFICATION"
        case .approvedTradeNotification:
            return "APPROVED_TRADE_NOTIFICATION"
        case .trackingNumberNotification:
            return "TRACKING_NUMBER_NOTIFICATION"
        case .trackingStatusNotification:
            return "TRACKING_STATUS_NOTIFICATION"
        case .modifiedItemNotification:
            return "MODIFIED_ITEM_NOTIFICATION"
        case .keepAliveNotification:
            return "KEEP_ALIVE_NOTIFICATION"
        }
    }
    
    var actionsForMinimalContext: [NotificationAction] {
        return [.show, .cancel]
    }
    
    var actionsForDefaultContext: [NotificationAction] {
        switch self {
        default: return actionsForMinimalContext
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
        case "POTENTIAL_TRADES_NOTIFICATION":
            return .potentialTradesNotification
        case "APPROVED_TRADE_NOTIFICATION":
            guard let tradeTransactionId = userInfo?["trade_transaction_id"] as? Int else { return nil }
            return .approvedTradeNotification(tradeTransactionId: tradeTransactionId)
        case "TRACKING_NUMBER_NOTIFICATION":
            guard let tradeTransactionId = userInfo?["trade_transaction_id"] as? Int else { return nil }
            return .trackingNumberNotification(tradeTransactionId: tradeTransactionId)
        case "TRACKING_STATUS_NOTIFICATION":
            guard let tradeTransactionId = userInfo?["trade_transaction_id"] as? Int else { return nil }
            return .trackingStatusNotification(tradeTransactionId: tradeTransactionId)
        case "MODIFIED_ITEM_NOTIFICATION":
            guard let itemId = userInfo?["item_id"] as? Int else { return nil }
            return .modifiedItemNotification(itemId: itemId)
        case "KEEP_ALIVE_NOTIFICATION":
            return .keepAliveNotification
        default:
            return nil
        }
    }
}
