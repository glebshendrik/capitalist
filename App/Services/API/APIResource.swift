//
//  APIResourceKeyPath.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct APIResource {
    let singular: String
    let plural: String
    
    static func resource(for route: APIRoute) -> APIResource {
        switch route {
        case .createUser,
             .showUser,
             .updateUser,
             .updateUserSettings,
             .changePassword,
             .resetPassword,
             .updateDeviceToken:
            return APIResource(singular: "user", plural: "users")
        case .createPasswordResetCode:
            return APIResource(singular: "password_reset_code", plural: "password_reset_codes")
        case .createSession,
             .destroySession:
            return APIResource(singular: "session", plural: "sessions")
        case .createIncomeSource,
             .showIncomeSource,
             .indexIncomeSources,
             .updateIncomeSource,
             .updateIncomeSourcePosition,
             .destroyIncomeSource:
            return APIResource(singular: "income_source", plural: "income_sources")
        case .createExpenseSource,
             .showExpenseSource,
             .firstExpenseSource,
             .indexExpenseSources,
             .updateExpenseSource,
             .updateExpenseSourcePosition,
             .destroyExpenseSource:
            return APIResource(singular: "expense_source", plural: "expense_sources")
        case .createExpenseCategory,
             .showExpenseCategory,
             .indexExpenseCategories,
             .indexUserExpenseCategories,
             .updateExpenseCategory,
             .updateExpenseCategoryPosition,
             .destroyExpenseCategory:
            return APIResource(singular: "expense_category", plural: "expense_categories")
        case .indexIcons:
            return APIResource(singular: "icon", plural: "icons")
        case .indexBaskets,
             .showBasket:
            return APIResource(singular: "basket", plural: "baskets")
        case .indexCurrencies:
            return APIResource(singular: "currency", plural: "currencies")
        case .createIncome,
             .showIncome,
             .updateIncome,
             .destroyIncome:
            return APIResource(singular: "income", plural: "incomes")
        case .createExpense,
             .showExpense,
             .updateExpense,
             .destroyExpense:
            return APIResource(singular: "expense", plural: "expenses")
        case .createFundsMove,
             .showFundsMove,
             .updateFundsMove,
             .destroyFundsMove:
            return APIResource(singular: "funds_move", plural: "funds_moves")
        case .findExchangeRate:
            return APIResource(singular: "exchange_rate", plural: "exchange_rates")
        case .showBudget:
            return APIResource(singular: "budget", plural: "budgets")
        case .indexHistoryTransactions:
            return APIResource(singular: "history_transaction", plural: "history_transactions")
        case .indexAccountConnections,
             .destroyAccountConnection:
            return APIResource(singular: "account_connection", plural: "account_connections")
        case .indexProviderConnections,
             .createProviderConnection:
            return APIResource(singular: "provider_connection", plural: "provider_connections")
        case .createDebt,
             .showDebt,
             .indexDebts,
             .updateDebt,
             .destroyDebt:
            return APIResource(singular: "debt", plural: "debts")
        case .createLoan,
             .showLoan,
             .indexLoans,
             .updateLoan,
             .destroyLoan:
            return APIResource(singular: "loan", plural: "loans")
        }
    }
}
