//
//  APIRouteMethod.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct APIRouteMethod {
    static func method(for route: APIRoute) -> HTTPMethod {        
        switch route {
        case .createUser,
             .createSession,
             .createPasswordResetCode,
             .createIncomeSource,
             .createExpenseSource,
             .createExpenseCategory,
             .createTransaction,
             .createProviderConnection,
             .createDebt,
             .createLoan,
             .createCredit,
             .createActive:
            return .post
        case .showUser,
             .showIncomeSource,
             .firstBorrowIncomeSource,
             .indexIncomeSources,
             .showExpenseSource,
             .firstExpenseSource,
             .indexExpenseSources,
             .indexIcons,
             .indexBaskets,
             .showBasket,
             .firstBorrowExpenseCategory,
             .indexExpenseCategories,
             .indexUserExpenseCategories,
             .showExpenseCategory,
             .indexCurrencies,
             .findExchangeRate,
             .showBudget,
             .indexTransactions,
             .showTransaction,
             .indexAccountConnections,
             .indexProviderConnections,
             .indexDebts,
             .showDebt,
             .indexLoans,
             .showLoan,
             .indexCredits,
             .showCredit,
             .indexCreditTypes,
             .indexActives,
             .indexUserActives,
             .showActive,
             .indexActiveTypes,
             .indexTransactionableExamples:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .updateIncomeSource,
             .updateExpenseSource,
             .updateExpenseCategory,
             .updateTransaction,
             .updateDebt,
             .updateLoan,
             .updateCredit,
             .updateActive,
             .onboardUser:
            return .put
        case .updateIncomeSourcePosition,
             .updateExpenseSourcePosition,
             .updateExpenseCategoryPosition,
             .updateUserSettings,
             .updateDeviceToken,
             .updateActivePosition:
            return .patch
        case .destroySession,
             .destroyIncomeSource,
             .destroyExpenseSource,
             .destroyExpenseCategory,
             .destroyTransaction,
             .destroyAccountConnection,
             .destroyDebt,
             .destroyLoan,
             .destroyCredit,
             .destroyActive:
            return .delete
        }
    }
}
