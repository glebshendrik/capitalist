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
        case .changePassword(let form):                     return "/users/\(form.userId)/password"
        case .resetPassword:                                return "/users/new_password"
        case .createPasswordResetCode:                      return "/password_reset_codes"
        case .registerDeviceToken(_, let userId):           return "/users/\(userId)/device_token"
        case .createSession:                                return "/sessions"
        case .destroySession(let session):                  return "/sessions/\(session.token)"
        case .createIncomeSource(let form):                 return "/users/\(form.userId)/income_sources"
        case .showIncomeSource(let id):                     return "/income_sources/\(id)"
        case .indexIncomeSources(let userId):               return "/users/\(userId)/income_sources"
        case .updateIncomeSource(let form):                 return "/income_sources/\(form.id)"
        case .updateIncomeSourcePosition(let form):         return "/income_sources/\(form.id)"            
        case .destroyIncomeSource(let id):                  return "/income_sources/\(id)"
        case .createExpenseSource(let form):                return "/users/\(form.userId)/expense_sources"
        case .showExpenseSource(let id):                    return "/expense_sources/\(id)"
        case .indexExpenseSources(let userId):              return "/users/\(userId)/expense_sources"
        case .updateExpenseSource(let form):                return "/expense_sources/\(form.id)"
        case .updateExpenseSourcePosition(let form):        return "/expense_sources/\(form.id)"
        case .destroyExpenseSource(let id):                 return "/expense_sources/\(id)"
        case .createExpenseCategory(let form):              return "/baskets/\(form.basketId)/expense_categories"
        case .showExpenseCategory(let id):                  return "/expense_categories/\(id)"
        case .indexExpenseCategories(let basketId):         return "/baskets/\(basketId)/expense_categories"
        case .updateExpenseCategory(let form):              return "/expense_categories/\(form.id)"
        case .updateExpenseCategoryPosition(let form):       return "/expense_categories/\(form.id)"
        case .destroyExpenseCategory(let id):               return "/expense_categories/\(id)"
        case .indexIcons:                                   return "/icons"
        case .indexBaskets(let userId):                     return "/users/\(userId)/baskets"
        case .showBasket(let id):                           return "/baskets/\(id)"
        case .indexCurrencies:                              return "/currencies"
        }
    }
}
