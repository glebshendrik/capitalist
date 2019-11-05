//
//  APIRouteQueryParameters.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

struct APIRouteQueryParameters {
    static func queryParameters(for route: APIRoute) -> [String : String] {
        let params = [String : String]()
        switch route {
        case .indexIcons(let category):
            return [ "category" : category.rawValue ]
        case .findExchangeRate(let from, let to):
            return [ "from" : from, "to" : to ]
        case .destroyIncomeSource(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .destroyExpenseSource(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .destroyExpenseCategory(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .destroyDebt(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .destroyLoan(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .destroyCredit(_, let deleteTransactions):
            return [ "delete_transactions" : deleteTransactions.string ]
        case .firstBorrowIncomeSource(_, let currency):
            return [ "currency" : currency ]
        case .indexIncomeSources(_, let noBorrows):
            return [ "no_borrows" : noBorrows.string ]
        case .firstExpenseSource(_, let currency, let isVirtual):
            return [ "currency" : currency, "is_virtual" : isVirtual.string ]
        case .indexExpenseSources(_, let currency):
            if let currency = currency {
                return [ "currency" : currency ]
            }
            return params
        case .firstBorrowExpenseCategory(_, let currency):
            return [ "currency" : currency ]
        case .indexExpenseCategories(_, let noBorrows):
            return [ "no_borrows" : noBorrows.string ]
        case .indexUserExpenseCategories(_, let noBorrows):
            return [ "no_borrows" : noBorrows.string ]
        case .indexTransactions(_, let type):
            guard let type = type else { return params }
            return [ "transaction_type" : type.rawValue ]
        case .indexProviderConnections(_, let providerId):
            return [ "provider_id" : providerId ]
        case .indexAccountConnections(_, let connectionId):
            return [ "connection_id" : connectionId ]
        default:
            break
        }
        return params
    }
}
