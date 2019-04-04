//
//  APIResourceMethod.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
             .createFundsMove:
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
             .showExpenseCategory,
             .indexCurrencies,
             .findExchangeRate,
             .showBudget,
             .indexHistoryTransactions,
             .showIncome,
             .showExpense,
             .showFundsMove:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .registerDeviceToken,
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
             .updateUserSettings:
            return .patch
        case .destroySession,
             .destroyIncomeSource,
             .destroyExpenseSource,
             .destroyExpenseCategory,
             .destroyIncome,
             .destroyExpense,
             .destroyFundsMove:
            return .delete
        }
    }
}
