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
        var params = [String : String]()
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
        case .destroyActive(_, let deleteTransactions):
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
        case .indexTransactionableExamples(let transactionableType, let basketType):
            params["transactionable_type"] = transactionableType.rawValue
            if let basketType = basketType {
                params["basket_type"] = basketType.rawValue
            }
            if let country = Locale.current.regionCode {
                params["country"] = country
            }
            return params
        case .indexTransactions(_, let type, let transactionableId, let transactionableType, let creditId, let borrowId, let borrowType, let count, let lastGotAt, let fromGotAt, let toGotAt):
            if let type = type {
                params["transaction_type"] = type.rawValue
            }
            if let transactionableId = transactionableId {
                params["transactionable_id"] = transactionableId.string
            }
            if let transactionableType = transactionableType {
                params["transactionable_type"] = transactionableType.rawValue
            }
            if let creditId = creditId {
                params["credit_id"] = creditId.string
            }
            if let borrowId = borrowId {
                params["borrow_id"] = borrowId.string
            }
            if let borrowType = borrowType {
                params["borrow_type"] = borrowType.rawValue
            }
            if let count = count {
                params["count"] = count.string
            }
            if let lastGotAt = lastGotAt {
                params["last_got_at"] = Formatter.iso8601.string(from: lastGotAt)
            }
            if let fromGotAt = fromGotAt {
                params["from_got_at"] = Formatter.iso8601.string(from: fromGotAt)
            }
            if let toGotAt = toGotAt {
                params["to_got_at"] = Formatter.iso8601.string(from: toGotAt)
            }
            return params
        case .indexConnections(_, let providerId):
            return [ "provider_id" : providerId ]
        case .indexAccounts(_, let currencyCode, let connectionId, let providerId, let notUsed, let nature):
            if let currencyCode = currencyCode {
                params["currency"] = currencyCode
            }
            params["connection_id"] = connectionId
            params["provider_id"] = providerId
            params["not_attached"] = notUsed.string
            params["nature_type"] = nature.rawValue
            return params
        default:
            break
        }
        return params
    }
}
