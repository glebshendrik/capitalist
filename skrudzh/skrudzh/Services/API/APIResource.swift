//
//  APIResource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDate

enum APIResource: URLRequestConvertible {
    static var baseURLString: String {
        #if DEBUG
            return "https://skrudzh-staging.herokuapp.com"
        #else
            return "https://skrudzh-production.herokuapp.com"
        #endif
    }
    
    // Users
    case createUser(form: UserCreationForm)
    case showUser(id: Int)
    case updateUser(form: UserUpdatingForm)
    case updateUserSettings(form: UserSettingsUpdatingForm)
    case changePassword(form: ChangePasswordForm)
    case resetPassword(form: ResetPasswordForm)
    case createPasswordResetCode(form: PasswordResetCodeForm)
    case registerDeviceToken(deviceToken: String, userId: Int)
    
    // Sessions
    case createSession(form: SessionCreationForm)
    case destroySession(session: Session)
    
    // IncomeSources
    case createIncomeSource(form: IncomeSourceCreationForm)
    case showIncomeSource(id: Int)
    case indexIncomeSources(userId: Int)
    case updateIncomeSource(form: IncomeSourceUpdatingForm)
    case updateIncomeSourcePosition(form: IncomeSourcePositionUpdatingForm)
    case destroyIncomeSource(id: Int)
    
    // ExpenseSources
    case createExpenseSource(form: ExpenseSourceCreationForm)
    case showExpenseSource(id: Int)
    case indexExpenseSources(userId: Int)
    case updateExpenseSource(form: ExpenseSourceUpdatingForm)
    case updateExpenseSourcePosition(form: ExpenseSourcePositionUpdatingForm)
    case destroyExpenseSource(id: Int)
    
    // ExpenseCategories
    case createExpenseCategory(form: ExpenseCategoryCreationForm)
    case showExpenseCategory(id: Int)
    case indexExpenseCategories(basketId: Int)
    case updateExpenseCategory(form: ExpenseCategoryUpdatingForm)
    case updateExpenseCategoryPosition(form: ExpenseCategoryPositionUpdatingForm)
    case destroyExpenseCategory(id: Int)
    
    // Icons
    case indexIcons(category: IconCategory)
    
    // Baskets
    case indexBaskets(userId: Int)
    case showBasket(id: Int)
    
    // Currencies
    case indexCurrencies
    
    // Incomes
    case createIncome(form: IncomeCreationForm)
    case updateIncome(form: IncomeUpdatingForm)
    case destroyIncome(id: Int)
    
    // Expenses
    case createExpense(form: ExpenseCreationForm)
    case updateExpense(form: ExpenseUpdatingForm)
    case destroyExpense(id: Int)
    
    // FundsMoves
    case createFundsMove(form: FundsMoveCreationForm)
    case updateFundsMove(form: FundsMoveUpdatingForm)
    case destroyFundsMove(id: Int)
    
    // ExchangeRates
    case findExchangeRate(from: String, to: String)
    
    var method: HTTPMethod {
        return APIResourceMethod.method(for: self)
    }
    
    var path: String {
        return APIResourcePath.path(for: self)
    }
    
    var keyPath: ResourceKeyPath {
        return APIResourceKeyPath.keyPath(for: self)
    }
    
    var urlStringQueryParameters: [String : String] {
        return APIResourceQueryParameters.queryParameters(for: self)
    }
    
    // MARK: URLRequestConvertible    
    func asURLRequest() throws -> URLRequest {
        return try APIResourceRequest.urlRequest(for: self)
    }
}
