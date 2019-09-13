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
        case .firstExpenseSource(_, let accountType, let currency):
            return [ "account_type" : accountType.rawValue, "currency" : currency ]
        case .indexExpenseSources(_, let noDebts, let currency):
            if let currency = currency {
                return [ "no_debts" : noDebts.string, "currency" : currency ]
            }
            return [ "no_debts" : noDebts.string ]
        case .indexUserExpenseCategories(_, let includedInBalance):
            return [ "included_in_balance" : includedInBalance.string ]
        case .createIncome(_, let shouldCloseActive):
            return [ "close_active" : shouldCloseActive.string ]
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
