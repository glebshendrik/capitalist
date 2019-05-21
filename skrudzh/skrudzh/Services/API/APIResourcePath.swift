//
//  APIResourcePath.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct APIResourcePath {
    static func path(for resource: APIResource) -> String {
        switch resource {
        case .createUser:                                   return "/users"
        case .showUser(let id):                             return "/users/\(id)"
        case .updateUser(let form):                         return "/users/\(form.userId)"
        case .updateUserSettings(let form):                 return "/users/\(form.userId)"
        case .updateDeviceToken(let form):                  return "/users/\(form.userId)"
        case .changePassword(let form):                     return "/users/\(form.userId)/password"
        case .resetPassword:                                return "/users/new_password"
        case .createPasswordResetCode:                      return "/password_reset_codes"
        case .createSession:                                return "/sessions"
        case .destroySession(let session):                  return "/sessions/\(session.token)"
        case .createIncomeSource(let form):                 return "/users/\(form.userId)/income_sources"
        case .showIncomeSource(let id):                     return "/income_sources/\(id)"
        case .indexIncomeSources(let userId):               return "/users/\(userId)/income_sources"
        case .updateIncomeSource(let form):                 return "/income_sources/\(form.id)"
        case .updateIncomeSourcePosition(let form):         return "/income_sources/\(form.id)"            
        case .destroyIncomeSource(let id, _):               return "/income_sources/\(id)"
        case .createExpenseSource(let form):                return "/users/\(form.userId)/expense_sources"
        case .showExpenseSource(let id):                    return "/expense_sources/\(id)"
        case .indexExpenseSources(let userId, _):           return "/users/\(userId)/expense_sources"
        case .updateExpenseSource(let form):                return "/expense_sources/\(form.id)"
        case .updateExpenseSourcePosition(let form):        return "/expense_sources/\(form.id)"
        case .destroyExpenseSource(let id, _):              return "/expense_sources/\(id)"
        case .createExpenseCategory(let form):              return "/baskets/\(form.basketId)/expense_categories"
        case .showExpenseCategory(let id):                  return "/expense_categories/\(id)"
        case .indexExpenseCategories(let basketId):         return "/baskets/\(basketId)/expense_categories"
        case .indexUserExpenseCategories(let userId, _):    return "/users/\(userId)/expense_categories"
        case .updateExpenseCategory(let form):              return "/expense_categories/\(form.id)"
        case .updateExpenseCategoryPosition(let form):      return "/expense_categories/\(form.id)"
        case .destroyExpenseCategory(let id, _):            return "/expense_categories/\(id)"
        case .indexIcons:                                   return "/icons"
        case .indexBaskets(let userId):                     return "/users/\(userId)/baskets"
        case .showBasket(let id):                           return "/baskets/\(id)"
        case .indexCurrencies:                              return "/currencies"
        case .createIncome(let form, _):                    return "/users/\(form.userId)/incomes"
        case .showIncome(let id):                           return "/incomes/\(id)"
        case .updateIncome(let form):                       return "/incomes/\(form.id)"
        case .destroyIncome(let id):                        return "/incomes/\(id)"
        case .findExchangeRate:                             return "/exchange_rates/find_by"
        case .createExpense(let form):                      return "/users/\(form.userId)/expenses"
        case .showExpense(let id):                          return "/expenses/\(id)"
        case .updateExpense(let form):                      return "/expenses/\(form.id)"
        case .destroyExpense(let id):                       return "/expenses/\(id)"
        case .createFundsMove(let form):                    return "/users/\(form.userId)/funds_moves"
        case .showFundsMove(let id):                        return "/funds_moves/\(id)"
        case .updateFundsMove(let form):                    return "/funds_moves/\(form.id)"
        case .destroyFundsMove(let id):                     return "/funds_moves/\(id)"
        case .showBudget(let userId):                       return "/users/\(userId)/budget"
        case .indexHistoryTransactions(let userId):         return "/users/\(userId)/history_transactions"
        }
    }
}
