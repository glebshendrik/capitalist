//
//  APIResource.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDate

enum APIRoute: URLRequestConvertible {
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
    case updateDeviceToken(form: UserDeviceTokenUpdatingForm)
    
    // Sessions
    case createSession(form: SessionCreationForm)
    case destroySession(session: Session)
    
    // IncomeSources
    case createIncomeSource(form: IncomeSourceCreationForm)
    case showIncomeSource(id: Int)
    case indexIncomeSources(userId: Int)
    case updateIncomeSource(form: IncomeSourceUpdatingForm)
    case updateIncomeSourcePosition(form: IncomeSourcePositionUpdatingForm)
    case destroyIncomeSource(id: Int, deleteTransactions: Bool)
    
    // ExpenseSources
    case createExpenseSource(form: ExpenseSourceCreationForm)
    case showExpenseSource(id: Int)
    case firstExpenseSource(userId: Int, accountType: AccountType, currency: String)
    case indexExpenseSources(userId: Int, noDebts: Bool, currency: String?)
    case updateExpenseSource(form: ExpenseSourceUpdatingForm)
    case updateExpenseSourcePosition(form: ExpenseSourcePositionUpdatingForm)
    case destroyExpenseSource(id: Int, deleteTransactions: Bool)
    
    // ExpenseCategories
    case createExpenseCategory(form: ExpenseCategoryCreationForm)
    case showExpenseCategory(id: Int)
    case indexExpenseCategories(basketId: Int)
    case indexUserExpenseCategories(userId: Int, includedInBalance: Bool)
    case updateExpenseCategory(form: ExpenseCategoryUpdatingForm)
    case updateExpenseCategoryPosition(form: ExpenseCategoryPositionUpdatingForm)
    case destroyExpenseCategory(id: Int, deleteTransactions: Bool)
    
    // Icons
    case indexIcons(category: IconCategory)
    
    // Baskets
    case indexBaskets(userId: Int)
    case showBasket(id: Int)
    
    // Currencies
    case indexCurrencies
    
    // Incomes
    case createIncome(form: IncomeCreationForm, shouldCloseActive: Bool)
    case showIncome(id: Int)
    case updateIncome(form: IncomeUpdatingForm)
    case destroyIncome(id: Int)
    
    // Expenses
    case createExpense(form: ExpenseCreationForm)
    case showExpense(id: Int)
    case updateExpense(form: ExpenseUpdatingForm)
    case destroyExpense(id: Int)
    
    // FundsMoves
    case createFundsMove(form: FundsMoveCreationForm)
    case showFundsMove(id: Int)
    case updateFundsMove(form: FundsMoveUpdatingForm)
    case destroyFundsMove(id: Int)
    
    // Debts
    case createDebt(form: BorrowCreationForm)
    case indexDebts(userId: Int)
    case showDebt(id: Int)
    case updateDebt(form: BorrowUpdatingForm)
    case destroyDebt(id: Int, deleteTransactions: Bool)
    
    // Loans
    case createLoan(form: BorrowCreationForm)
    case indexLoans(userId: Int)
    case showLoan(id: Int)
    case updateLoan(form: BorrowUpdatingForm)
    case destroyLoan(id: Int, deleteTransactions: Bool)
    
    // ExchangeRates
    case findExchangeRate(from: String, to: String)
    
    // Budget
    case showBudget(userId: Int)
    
    // HistoryTransactions
    case indexHistoryTransactions(userId: Int)
    
    // AccountConnections
    case indexAccountConnections(userId: Int, connectionId: String)
    case destroyAccountConnection(id: Int)
    
    // ProviderConnections
    case indexProviderConnections(userId: Int, providerId: String)
    case createProviderConnection(form: ProviderConnectionCreationForm)
    
    var method: HTTPMethod {
        return APIRouteMethod.method(for: self)
    }
    
    var path: String {
        return APIRoutePath.path(for: self)
    }
    
    var resource: APIResource {
        return APIResource.resource(for: self)
    }
    
    var urlStringQueryParameters: [String : String] {
        return APIRouteQueryParameters.queryParameters(for: self)
    }
    
    // MARK: URLRequestConvertible    
    func asURLRequest() throws -> URLRequest {
        return try APIRouteRequest.urlRequest(for: self)
    }
}
