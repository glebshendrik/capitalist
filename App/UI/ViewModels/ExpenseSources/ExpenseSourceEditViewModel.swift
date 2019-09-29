//
//  ExpenseSourceEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseSourceUpdatingError : Error {
    case updatingExpenseSourceIsNotSpecified
}

class ExpenseSourceEditViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    private var expenseSource: ExpenseSource? = nil
    
    var accountType: AccountType = .usual
    var selectedIconURL: URL? = nil
    var selectedCurrency: Currency? = nil
    var name: String? = nil
    var amount: String? = nil
    var creditLimit: String? = nil
    var goalAmount: String? = nil
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    // Computed
    
    var isNew: Bool {
        return expenseSource == nil
    }
    
    var defaultIconName: String {
        return iconCategory.defaultIconName
    }

    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
    
    var iconCategory: IconCategory {
        switch accountType {
        case .usual:
            return .expenseSource
        case .goal:
            return .expenseSourceGoal
        case .debt:
            return .expenseSourceDebt
        }
    }
    
    var accountConnected: Bool {
        guard let accountConnectionAttributes = accountConnectionAttributes else {
            return false
        }
        
        return accountConnectionAttributes.shouldDestroy == nil
    }
    
    var bankButtonTitle: String {
        return accountConnected ? "Отключить банк" : "Подключить банк"
    }
    
    // Permissions
    
    var canChangeIcon: Bool {
        return !accountConnected
    }
    
    var canChangeCurrency: Bool {
        return !accountConnected && isNew
    }
    
    var canChangeAmount: Bool {
        return !accountConnected && (isNew || accountType != .debt)
    }
    
    var canChangeCreditLimit: Bool {
        return !accountConnected
    }
    
    // Visibility
    
    var typeSwitchHidden: Bool {
        return !isNew
    }
    
    var typeLabelHidden: Bool {
        return isNew
    }
    
    var iconPenHidden: Bool {
        return !canChangeIcon
    }
    
    var customIconHidden: Bool {
        return accountConnected
    }
    
    var bankIconHidden: Bool {
        return !accountConnected
    }
    
    var amountHidden: Bool {
        return isNew && accountType == .debt
    }
    
    var creditLimitHidden: Bool {
        return accountType != .usual
    }
    
    var goalAmountHidden: Bool {
        return accountType != .goal
    }
    
    var bankButtonHidden: Bool {
        return accountType != .usual
    }
    
    var removeButtonHidden: Bool {
        return isNew
    }
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func set(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        
        accountType = expenseSource.accountType
        selectedIconURL = expenseSource.iconURL
        selectedCurrency = expenseSource.currency
        name = expenseSource.name
        amount = expenseSource.amountCents.moneyDecimalString(with: selectedCurrency)
        creditLimit = expenseSource.creditLimitCents?.moneyDecimalString(with: selectedCurrency)
        goalAmount = expenseSource.goalAmountCents?.moneyDecimalString(with: selectedCurrency)
        
        if let accountConnection = expenseSource.accountConnection {
            accountConnectionAttributes =
                AccountConnectionNestedAttributes(id: accountConnection.id,
                                                  providerConnectionId: accountConnection.providerConnection.id,
                                                  accountId: accountConnection.accountId,
                                                  accountName: accountConnection.accountName,
                                                  nature: accountConnection.nature,
                                                  currencyCode: accountConnection.currencyCode,
                                                  balance: accountConnection.balance,
                                                  connectionId: accountConnection.connectionId,
                                                  shouldDestroy: nil)
        }
        
    }
    
    func isFormValid() -> Bool {
        return isNew
            ? isCreationFormValid()
            : isUpdatingFormValid()
    }
    
    func save() -> Promise<Void> {
        return isNew
            ? create()
            : update()
    }
    
    func removeExpenseSource(deleteTransactions: Bool) -> Promise<Void> {
        guard let expenseSourceId = expenseSource?.id else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        return expenseSourcesCoordinator.destroy(by: expenseSourceId, deleteTransactions: deleteTransactions)
    }
    
    
}

// Creation
extension ExpenseSourceEditViewModel {
    private func create() -> Promise<Void> {
        return expenseSourcesCoordinator.create(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ExpenseSourceCreationForm {
        return ExpenseSourceCreationForm(userId: accountCoordinator.currentSession?.userId,
                                         name: name,
                                         iconURL: selectedIconURL,
                                         amountCurrency: selectedCurrency?.code,
                                         amountCents: (amount ?? "0").intMoney(with: selectedCurrency),
                                         accountType: accountType,
                                         goalAmountCents: goalAmount?.intMoney(with: selectedCurrency),
                                         goalAmountCurrency: selectedCurrency?.code,
                                         creditLimitCents: (creditLimit ?? "0").intMoney(with: selectedCurrency),
                                         creditLimitCurrency: selectedCurrency?.code,
                                         accountConnectionAttributes: accountConnectionAttributes)
    }
}

// Updating
extension ExpenseSourceEditViewModel {
    private func update() -> Promise<Void> {
        return expenseSourcesCoordinator.update(with: updatingForm())
    }
    
    private func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> ExpenseSourceUpdatingForm {
        return ExpenseSourceUpdatingForm(id: expenseSource?.id,
                                         accountType: accountType,
                                         name: name,
                                         amountCents: amount?.intMoney(with: selectedCurrency),
                                         iconURL: selectedIconURL,
                                         goalAmountCents: goalAmount?.intMoney(with: selectedCurrency),
                                         creditLimitCents: creditLimit?.intMoney(with: selectedCurrency),
                                         accountConnectionAttributes: accountConnectionAttributes)
    }
}

// Bank Connection
extension ExpenseSourceEditViewModel {
    func connect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        selectedCurrency = accountViewModel.currency
        selectedIconURL = providerConnection.logoURL
        
        if name == nil {
            name = accountViewModel.name
        }
        
        amount = accountViewModel.amount
        
        if let creditLimit = accountViewModel.creditLimit {
            self.creditLimit = creditLimit
        }
        
        var accountConnectionId: Int? = nil
        if  let accountConnectionAttributes = accountConnectionAttributes,
            accountConnectionAttributes.accountId == accountViewModel.id {
            
            accountConnectionId = accountConnectionAttributes.id
        }
        
        accountConnectionAttributes =
            AccountConnectionNestedAttributes(id: accountConnectionId,
                                              providerConnectionId: providerConnection.id,
                                              accountId: accountViewModel.id,
                                              accountName: accountViewModel.name,
                                              nature: accountViewModel.nature,
                                              currencyCode: accountViewModel.currencyCode,
                                              balance: accountViewModel.amountCents ?? 0,
                                              connectionId: providerConnection.connectionId,
                                              shouldDestroy: nil)
    }
    
    func removeAccountConnection() {
        accountConnectionAttributes?.id = expenseSource?.accountConnection?.id
        accountConnectionAttributes?.shouldDestroy = true
        selectedIconURL = nil
    }
    
    func loadProviderConnection(for providerId: String) -> Promise<ProviderConnection> {
        return bankConnectionsCoordinator.loadProviderConnection(for: providerId)
    }
    
    func createBankConnectionSession(for providerViewModel: ProviderViewModel) -> Promise<ProviderViewModel> {
        let languageCode = String(Locale.preferredLanguages[0].prefix(2)).lowercased()
        return  firstly {
            bankConnectionsCoordinator.createSaltEdgeConnectSession(providerCode: providerViewModel.code,
                                                                    languageCode: languageCode)
            }.then { connectURL -> Promise<ProviderViewModel> in
                providerViewModel.connectURL = connectURL
                return Promise.value(providerViewModel)
        }
    }
    
    func createProviderConnection(connectionId: String, connectionSecret: String, providerViewModel: ProviderViewModel) -> Promise<ProviderConnection> {
        return bankConnectionsCoordinator.createProviderConnection(connectionId: connectionId, connectionSecret: connectionSecret, provider: providerViewModel.provider)
    }
}
