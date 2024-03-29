//
//  APIResource.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDate
import SwifterSwift

enum APIRoute: URLRequestConvertible {
    static var baseURLKey: String {
        return "baseURLString"
    }
    
    static var storedBaseURLString: String? {
        return UserDefaults.standard.string(forKey: APIRoute.baseURLKey)
    }
    
    static var baseURLString: String {
        switch UIApplication.shared.inferredEnvironment {
        case .debug:
//            return storedBaseURLString ?? "https://skrudz.tempio.app"
//            return storedBaseURLString ?? "https://staging.threebaskets.net"
            return "https://staging.threebaskets.net"
//            return "https://api.threebaskets.net"
        case .testFlight:
//            return "https://skrudz.tempio.app"
            return storedBaseURLString ?? "https://api.threebaskets.net"
//            return storedBaseURLString ?? "https://api.threebaskets.net"
//            return "https://skrudz.tempio.app"
//            return "https://test.threebaskets.net"
        case .appStore:
//            return "https://skrudz.tempio.app"
            return "https://api.threebaskets.net"
        }
    }
    
    // Users
    case createUser(form: UserCreationForm)
    case showUser(id: Int)
    case updateUser(form: UserUpdatingForm)
    case updateUserSettings(form: UserSettingsUpdatingForm)
    case updateUserSubscription(form: UserSubscriptionUpdatingForm)
    case changePassword(form: ChangePasswordForm)
    case resetPassword(form: ResetPasswordForm)
    case createPasswordResetCode(form: PasswordResetCodeForm)
    case updateDeviceToken(form: UserDeviceTokenUpdatingForm)
    case onboardUser(id: Int)
    case destroyUserData(id: Int)
    case confirmUser(id: Int)
    
    // SaltEdgeCustomers
    case createCustomer(userId: Int)
    
    // Sessions
    case createSession(form: SessionCreationForm)
    case destroySession(session: Session)
    
    // IncomeSources
    case createIncomeSource(form: IncomeSourceCreationForm)
    case firstBorrowIncomeSource(userId: Int, currency: String)
    case showIncomeSource(id: Int)
    case indexIncomeSources(userId: Int, noBorrows: Bool)
    case updateIncomeSource(form: IncomeSourceUpdatingForm)
    case updateIncomeSourcePosition(form: IncomeSourcePositionUpdatingForm)
    case destroyIncomeSource(id: Int, deleteTransactions: Bool)
    
    // ExpenseSources
    case createExpenseSource(form: ExpenseSourceCreationForm)
    case showExpenseSource(id: Int)
    case firstExpenseSource(userId: Int, currency: String, isVirtual: Bool)
    case indexExpenseSources(userId: Int, currency: String?)
    case updateExpenseSource(form: ExpenseSourceUpdatingForm)
    case updateExpenseSourcePosition(form: ExpenseSourcePositionUpdatingForm)
    case updateExpenseSourceMaxFetchInterval(form: ExpenseSourceMaxFetchIntervalUpdatingForm)
    case destroyExpenseSource(id: Int, deleteTransactions: Bool)
    
    // ExpenseCategories
    case createExpenseCategory(form: ExpenseCategoryCreationForm)
    case showExpenseCategory(id: Int)
    case firstBorrowExpenseCategory(basketId: Int, currency: String)
    case indexExpenseCategories(basketId: Int, noBorrows: Bool)
    case indexUserExpenseCategories(userId: Int, noBorrows: Bool)
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
    
    // Transactions
    case indexTransactions( userId: Int,
                            type: TransactionType?,
                            transactionableId: Int?,
                            transactionableType: TransactionableType?,
                            creditId: Int?,
                            borrowId: Int?,
                            borrowType: BorrowType?,
                            count: Int?,
                            lastGotAt: Date?,
                            fromGotAt: Date?,
                            toGotAt: Date?)
    case createTransaction(form: TransactionCreationForm)
    case showTransaction(id: Int)
    case updateTransaction(form: TransactionUpdatingForm)
    case destroyTransaction(id: Int)
    case duplicateTransaction(id: Int)
        
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
    
    // Credits
    case createCredit(form: CreditCreationForm)
    case indexCredits(userId: Int)
    case showCredit(id: Int)
    case updateCredit(form: CreditUpdatingForm)
    case destroyCredit(id: Int, deleteTransactions: Bool)
    
    // CreditTypes
    case indexCreditTypes
    
    // Actives
    case createActive(form: ActiveCreationForm)
    case indexActives(basketId: Int)
    case indexUserActives(userId: Int)
    case showActive(id: Int)
    case updateActive(form: ActiveUpdatingForm)
    case updateActivePosition(form: ActivePositionUpdatingForm)
    case destroyActive(id: Int, deleteTransactions: Bool)
    
    // ActiveTypes
    case indexActiveTypes
    
    // ExchangeRates
    case findExchangeRate(from: String, to: String)
    case indexExchangeRates(userId: Int)
    
    // Budget
    case showBudget(userId: Int)
        
    // Accounts
    case indexAccounts(userId: Int, currencyCode: String?, connectionId: String, providerId: String, notUsed: Bool, nature: AccountNatureType)
    
    // Connections
    case indexConnections(userId: Int, providerId: String)
    case showConnection(id: Int)
    case createConnection(form: ConnectionCreationForm)
    case updateConnection(form: ConnectionUpdatingForm)
    
    // TransactionableExamples
    case indexTransactionableExamples(transactionableType: TransactionableType,
                                      basketType: BasketType?,
                                      isUsed: Bool?)
    
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
