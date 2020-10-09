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
        case .onboardUser(let id):                          return "/users/\(id)/onboard"
        case .confirmUser(let id):                          return "/users/\(id)/confirm"
        case .destroyUserData(let id):                      return "/users/\(id)/destroy_data"
        case .resetPassword:                                return "/users/new_password"
        case .findExchangeRate:                             return "/exchange_rates/find_by"
        case .firstExpenseSource(let userId, _, _):         return "\(collection(route, userId: userId))/first"
        case .firstBorrowIncomeSource(let userId, _):       return "\(collection(route, userId: userId))/first_borrow"
        case .firstBorrowExpenseCategory(let basketId, _):  return "\(collection(route, basketId: basketId))/first_borrow"
        case .duplicateTransaction(let id):                 return "/transactions/\(id)/duplicate"        
            
        // Create
        case .createUser:                                   return collection(route)
        case .createPasswordResetCode:                      return collection(route)
        case .createSession:                                return collection(route)
        case .createIncomeSource(let form):                 return collection(route, userId: form.userId)
        case .createExpenseSource(let form):                return collection(route, userId: form.userId)
        case .createExpenseCategory(let form):              return collection(route, basketId: form.basketId)
        case .createTransaction(let form):                  return collection(route, userId: form.userId)
        case .createConnection(let form):                   return collection(route, userId: form.userId)
        case .createDebt(let form):                         return collection(route, userId: form.userId)
        case .createLoan(let form):                         return collection(route, userId: form.userId)
        case .createCredit(let form):                       return collection(route, userId: form.userId)
        case .createActive(let form):                       return collection(route, basketId: form.basketId)
        
        // Index
        case .indexIcons,
             .indexCurrencies,
             .indexCreditTypes,
             .indexActiveTypes,
             .indexTransactionableExamples:                 return collection(route)
            
        case .indexExpenseCategories(let basketId, _):      return collection(route, basketId: basketId)
        case .indexActives(let basketId):                   return collection(route, basketId: basketId)
            
        case .indexIncomeSources(let userId, _),
             .indexExpenseSources(let userId, _),
             .indexUserExpenseCategories(let userId, _),
             .indexBaskets(let userId),
             .indexTransactions(let userId, _, _, _, _, _, _, _, _, _, _),
             .indexConnections(let userId, _),
             .indexAccounts(let userId, _, _, _, _, _),
             .indexDebts(let userId),
             .indexLoans(let userId),
             .indexCredits(let userId),
             .indexUserActives(let userId),
             .indexExchangeRates(let userId):                   return collection(route, userId: userId)
        
        // Update
        case .updateUser(let form):                             return member(route, id: form.userId)
        case .updateUserSettings(let form):                     return member(route, id: form.userId)
        case .updateUserSubscription(let form):                 return member(route, id: form.userId)
        case .updateDeviceToken(let form):                      return member(route, id: form.userId)
        case .updateIncomeSource(let form):                     return member(route, id: form.id)
        case .updateIncomeSourcePosition(let form):         	return member(route, id: form.id)
        case .updateExpenseSource(let form):                    return member(route, id: form.id)
        case .updateExpenseSourcePosition(let form):            return member(route, id: form.id)
        case .updateExpenseSourceMaxFetchInterval(let form):    return member(route, id: form.id)
        case .updateExpenseCategory(let form):                  return member(route, id: form.id)
        case .updateExpenseCategoryPosition(let form):          return member(route, id: form.id)
        case .updateTransaction(let form):                      return member(route, id: form.id)
        case .updateDebt(let form):                             return member(route, id: form.id)
        case .updateLoan(let form):                             return member(route, id: form.id)
        case .updateCredit(let form):                           return member(route, id: form.id)
        case .updateActive(let form):                           return member(route, id: form.id)
        case .updateActivePosition(let form):                   return member(route, id: form.id)
        case .updateConnection(let form):                       return member(route, id: form.id)
            
        // Show
        case .showUser(let id),
             .showIncomeSource(let id),
             .showExpenseSource(let id),
             .showExpenseCategory(let id),
             .showBasket(let id),
             .showTransaction(let id),
             .showDebt(let id),
             .showLoan(let id),
             .showCredit(let id),
             .showConnection(let id),
             .showActive(let id):                           return member(route, id: id)
            
        case .showBudget(let userId):                       return member(route, userId: userId)
        
        // Destroy
        case .destroyIncomeSource(let id, _),
             .destroyExpenseSource(let id, _),
             .destroyExpenseCategory(let id, _),
             .destroyTransaction(let id),
             .destroyDebt(let id, _),
             .destroyLoan(let id, _),
             .destroyCredit(let id, _),
             .destroyActive(let id, _):                     return member(route, id: id)
            
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
