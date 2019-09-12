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
             .createIncome,
             .createExpense,
             .createFundsMove,
             .createProviderConnection,
             .createDebt,
             .createLoan:
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
             .indexProviderConnections,
             .indexDebts,
             .showDebt,
             .indexLoans,
             .showLoan:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .updateIncomeSource,
             .updateExpenseSource,
             .updateExpenseCategory,
             .updateIncome,
             .updateExpense,
             .updateFundsMove,
             .updateDebt,
             .updateLoan:
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
             .destroyAccountConnection,
             .destroyDebt,
             .destroyLoan:
            return .delete
        }
    }
}
