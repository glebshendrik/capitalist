//
//  APIRoutePath.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

struct APIRoutePath {
    static func path(for route: APIRoute) -> String {
        switch route {
        // Custom        
        case .changePassword(let form):                     return "/users/\(form.userId!)/password"
        case .resetPassword:                                return "/users/new_password"
        case .findExchangeRate:                             return "/exchange_rates/find_by"
        case .firstExpenseSource(let userId, _, _):         return "\(collection(route, userId: userId))/first"
            
        // Create
        case .createUser:                                   return collection(route)
        case .createPasswordResetCode:                      return collection(route)
        case .createSession:                                return collection(route)
        case .createIncomeSource(let form):                 return collection(route, userId: form.userId)
        case .createExpenseSource(let form):                return collection(route, userId: form.userId)
        case .createExpenseCategory(let form):              return collection(route, basketId: form.basketId)
        case .createIncome(let form, _):                    return collection(route, userId: form.userId)
        case .createExpense(let form):                      return collection(route, userId: form.userId)
        case .createFundsMove(let form):                    return collection(route, userId: form.userId)
        case .createProviderConnection(let form):           return collection(route, userId: form.userId)
        case .createDebt(let form):                         return collection(route, userId: form.userId)
        case .createLoan(let form):                         return collection(route, userId: form.userId)
        
        // Index
        case .indexIcons:                                   return collection(route)
        case .indexCurrencies:                              return collection(route)
        case .indexIncomeSources(let userId):               return collection(route, userId: userId)        
        case .indexExpenseSources(let userId, _, _, _):     return collection(route, userId: userId)
        case .indexExpenseCategories(let basketId):         return collection(route, basketId: basketId)
        case .indexUserExpenseCategories(let userId, _):    return collection(route, userId: userId)
        case .indexBaskets(let userId):                     return collection(route, userId: userId)
        case .indexHistoryTransactions(let userId):         return collection(route, userId: userId)
        case .indexProviderConnections(let userId, _):      return collection(route, userId: userId)
        case .indexAccountConnections(let userId, _):       return collection(route, userId: userId)
        case .indexDebts(let userId):                       return collection(route, userId: userId)
        case .indexLoans(let userId):                       return collection(route, userId: userId)
        
        // Update
        case .updateUser(let form):                         return member(route, id: form.userId)        
        case .updateUserSettings(let form):                 return member(route, id: form.userId)
        case .updateDeviceToken(let form):                  return member(route, id: form.userId)
        case .updateIncomeSource(let form):                 return member(route, id: form.id)
        case .updateIncomeSourcePosition(let form):         return member(route, id: form.id)
        case .updateExpenseSource(let form):                return member(route, id: form.id)
        case .updateExpenseSourcePosition(let form):        return member(route, id: form.id)
        case .updateExpenseCategory(let form):              return member(route, id: form.id)
        case .updateExpenseCategoryPosition(let form):      return member(route, id: form.id)
        case .updateIncome(let form):                       return member(route, id: form.id)
        case .updateExpense(let form):                      return member(route, id: form.id)
        case .updateFundsMove(let form):                    return member(route, id: form.id)
        case .updateDebt(let form):                         return member(route, id: form.id)
        case .updateLoan(let form):                         return member(route, id: form.id)
            
        // Show
        case .showUser(let id):                             return member(route, id: id)
        case .showIncomeSource(let id):                     return member(route, id: id)
        case .showExpenseSource(let id):                    return member(route, id: id)
        case .showExpenseCategory(let id):                  return member(route, id: id)
        case .showBasket(let id):                           return member(route, id: id)
        case .showIncome(let id):                           return member(route, id: id)
        case .showExpense(let id):                          return member(route, id: id)
        case .showFundsMove(let id):                        return member(route, id: id)
        case .showDebt(let id):                             return member(route, id: id)
        case .showLoan(let id):                             return member(route, id: id)
        case .showBudget(let userId):                       return member(route, userId: userId)
        
        // Destroy
        case .destroyIncomeSource(let id, _):               return member(route, id: id)
        case .destroyExpenseSource(let id, _):              return member(route, id: id)
        case .destroyExpenseCategory(let id, _):            return member(route, id: id)
        case .destroyIncome(let id):                        return member(route, id: id)
        case .destroyExpense(let id):                       return member(route, id: id)
        case .destroyFundsMove(let id):                     return member(route, id: id)
        case .destroyAccountConnection(let id):             return member(route, id: id)
        case .destroyDebt(let id):                          return member(route, id: id)
        case .destroyLoan(let id):                          return member(route, id: id)
        case .destroySession(let session):                  return member(route, id: session.token)
        }
    }
    
    private static func collection(_ route: APIRoute, userId: Int?) -> String {
        return "/users/\(userId!)\(collection(route))"
    }
    
    private static func collection(_ route: APIRoute, basketId: Int?) -> String {
        return "/baskets/\(basketId!)\(collection(route))"
    }
    
    private static func collection(_ route: APIRoute) -> String {
        return "/\(APIResource.resource(for: route).plural)"
    }
    
    private static func member(_ route: APIRoute, id: Any?) -> String {
        return "\(collection(route))/\(id!)"
    }
    
    private static func member(_ route: APIRoute, userId: Int?) -> String {
        return "/users/\(userId!)/\(APIResource.resource(for: route).singular)"
    }
}
