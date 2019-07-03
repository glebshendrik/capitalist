//
//  APIResourceMethod.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct APIResourceMethod {
    static func method(for resource: APIResource) -> HTTPMethod {        
        switch resource {
        case .createUser,
             .createSession,
             .createPasswordResetCode,
             .createIncomeSource,
             .createExpenseSource,
             .createExpenseCategory,
             .createIncome,
             .createExpense,
             .createFundsMove,
             .createProviderConnection:
            return .post
        case .showUser,
             .showIncomeSource,
             .indexIncomeSources,
             .showExpenseSource,
             .indexExpenseSources,
             .indexIcons,
             .indexBaskets,
             .showBasket,
             .indexExpenseCategories,
             .indexUserExpenseCategories,
             .showExpenseCategory,
             .indexCurrencies,
             .findExchangeRate,
             .showBudget,
             .indexHistoryTransactions,
             .showIncome,
             .showExpense,
             .showFundsMove,
             .indexAccountConnections,
             .indexProviderConnections:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .updateIncomeSource,
             .updateExpenseSource,
             .updateExpenseCategory,
             .updateIncome,
             .updateExpense,
             .updateFundsMove:
            return .put
        case .updateIncomeSourcePosition,
             .updateExpenseSourcePosition,
             .updateExpenseCategoryPosition,
             .updateUserSettings,
             .updateDeviceToken:
            return .patch
        case .destroySession,
             .destroyIncomeSource,
             .destroyExpenseSource,
             .destroyExpenseCategory,
             .destroyIncome,
             .destroyExpense,
             .destroyFundsMove,
             .destroyAccountConnection:
            return .delete
        }
    }
}
