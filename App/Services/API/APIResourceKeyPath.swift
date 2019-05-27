//
//  APIResourceKeyPath.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct ResourceKeyPath {
    let singular: String
    let plural: String
}

struct APIResourceKeyPath {
    static func keyPath(for resource: APIResource) -> ResourceKeyPath {
        switch resource {
        case .createUser,
             .showUser,
             .updateUser,
             .updateUserSettings,
             .changePassword,
             .resetPassword,
             .updateDeviceToken:
            return ResourceKeyPath(singular: "user", plural: "users")
        case .createPasswordResetCode:
            return ResourceKeyPath(singular: "password_reset_code", plural: "password_reset_codes")
        case .createSession,
             .destroySession:
            return ResourceKeyPath(singular: "session", plural: "sessions")
        case .createIncomeSource,
             .showIncomeSource,
             .indexIncomeSources,
             .updateIncomeSource,
             .updateIncomeSourcePosition,
             .destroyIncomeSource:
            return ResourceKeyPath(singular: "income_source", plural: "income_sources")
        case .createExpenseSource,
             .showExpenseSource,
             .indexExpenseSources,
             .updateExpenseSource,
             .updateExpenseSourcePosition,
             .destroyExpenseSource:
            return ResourceKeyPath(singular: "expense_source", plural: "expense_sources")
        case .createExpenseCategory,
             .showExpenseCategory,
             .indexExpenseCategories,
             .indexUserExpenseCategories,
             .updateExpenseCategory,
             .updateExpenseCategoryPosition,
             .destroyExpenseCategory:
            return ResourceKeyPath(singular: "expense_category", plural: "expense_categories")
        case .indexIcons:
            return ResourceKeyPath(singular: "icon", plural: "icons")
        case .indexBaskets,
             .showBasket:
            return ResourceKeyPath(singular: "basket", plural: "baskets")
        case .indexCurrencies:
            return ResourceKeyPath(singular: "currency", plural: "currencies")
        case .createIncome,
             .showIncome,
             .updateIncome,
             .destroyIncome:
            return ResourceKeyPath(singular: "income", plural: "incomes")
        case .createExpense,
             .showExpense,
             .updateExpense,
             .destroyExpense:
            return ResourceKeyPath(singular: "expense", plural: "expenses")
        case .createFundsMove,
             .showFundsMove,
             .updateFundsMove,
             .destroyFundsMove:
            return ResourceKeyPath(singular: "funds_move", plural: "funds_moves")
        case .findExchangeRate:
            return ResourceKeyPath(singular: "exchange_rate", plural: "exchange_rates")
        case .showBudget:
            return ResourceKeyPath(singular: "budget", plural: "budgets")
        case .indexHistoryTransactions:
            return ResourceKeyPath(singular: "history_transaction", plural: "history_transactions")
        }
    }
}
