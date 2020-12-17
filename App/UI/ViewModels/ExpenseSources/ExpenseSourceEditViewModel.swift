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
    
    var selectedIconURL: URL? = nil
    var selectedCurrency: Currency? = nil
    var selectedCardType: CardType? = nil
    var name: String? = nil
    var amount: String? = nil
    var creditLimit: String? = nil
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    var amountToSave: String {
        guard   let amount = amount,
                !amount.isEmpty  else { return "0" }
        return amount
    }
    
    var creditLimitToSave: String {
        guard   let creditLimit = creditLimit,
                !creditLimit.isEmpty  else { return "0" }
        return creditLimit
    }
    
    // Computed
    
    var isNew: Bool {
        return expenseSource == nil
    }
    
    var defaultIconName: String {
        return TransactionableType.expenseSource.defaultIconName
    }
    
    var selectedCardTypeImageName: String? {
        return selectedCardType?.imageName
    }
    
    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
    
    var iconCategory: IconCategory {
        return .expenseSource
    }
    
    var accountConnected: Bool {
        guard let accountConnectionAttributes = accountConnectionAttributes else {
            return false
        }
        
        return accountConnectionAttributes.shouldDestroy == nil
    }
    
    var bankButtonTitle: String {
        return accountConnected
            ? NSLocalizedString("Отключить банк", comment: "Отключить банк")
            : NSLocalizedString("Подключить банк", comment: "Подключить банк")
    }
       
    var fetchDataFrom: Date? {
        return isNew ? Date()?.adding(.year, value: -1).adding(.day, value: 1).adding(.minute, value: 5) : expenseSource?.fetchDataFrom
    }
    
    var iconType: IconType {
        return selectedIconURL?.iconType ?? .raster
    }
    
    // Permissions
    
    var canChangeIcon: Bool {
        return !accountConnected
    }
    
    var canChangeCurrency: Bool {
        return !accountConnected && isNew
    }
    
    var canChangeAmount: Bool {
        return !accountConnected
    }
    
    var canChangeCreditLimit: Bool {
        return !accountConnected
    }
    
    var canCardType: Bool {
        return !accountConnected
    }
    
    var canConnectBank: Bool {
        return accountCoordinator.hasPlatinumSubscription
    }
    
    // Visibility
        
    var iconPenHidden: Bool {
        return !canChangeIcon
    }
    
    var customIconHidden: Bool {
        return accountConnected
    }
    
    var bankIconHidden: Bool {
        return !accountConnected
    }
                    
    var removeButtonHidden: Bool {
        return isNew
    }
    
    var bankButtonHidden: Bool {
        guard let currentUser = currentUser else {
            return true
        }
        return !currentUser.onboarded
    }
    
    var currentUser: User? = nil
    
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
                    self.currentUser = user
                }
    }
    
    func set(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        
        selectedIconURL = expenseSource.accountConnection?.account.connection.providerLogoURL ?? expenseSource.iconURL
        selectedCurrency = expenseSource.currency
        selectedCardType = expenseSource.cardType
        name = expenseSource.name
        amount = expenseSource.amountCents.moneyDecimalString(with: selectedCurrency)
        creditLimit = expenseSource.creditLimitCents?.moneyDecimalString(with: selectedCurrency)
        
        if let accountConnection = expenseSource.accountConnection {
            accountConnectionAttributes =
                AccountConnectionNestedAttributes(id: accountConnection.id,
                                                  accountId: accountConnection.account.id,                                                  
                                                  shouldDestroy: nil)
        }
        
    }
    
    func set(example: TransactionableExampleViewModel) {
        selectedIconURL = example.iconURL
        name = example.name
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
                                         currency: selectedCurrency?.code,
                                         amountCents: amountToSave.intMoney(with: selectedCurrency),
                                         creditLimitCents: creditLimitToSave.intMoney(with: selectedCurrency),
                                         cardType: selectedCardType,
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
                                         name: name,
                                         iconURL: selectedIconURL,
                                         amountCents: amountToSave.intMoney(with: selectedCurrency),          
                                         creditLimitCents: creditLimitToSave.intMoney(with: selectedCurrency),
                                         cardType: selectedCardType,
                                         accountConnectionAttributes: accountConnectionAttributes)
    }
}

// Bank Connection
extension ExpenseSourceEditViewModel {
    func connect(accountViewModel: AccountViewModel, connection: Connection) {
        selectedCurrency = accountViewModel.currency
        selectedIconURL = connection.providerLogoURL
        selectedCardType = accountViewModel.cardType
        
        if name == nil || isNew {
            name = accountViewModel.name
        }
        
        amount = accountViewModel.amountDecimal
        
        if let creditLimit = accountViewModel.creditLimitDecimal {
            self.creditLimit = creditLimit
        }
        
        var accountConnectionId: Int? = nil
        if  let accountConnectionAttributes = accountConnectionAttributes,
            accountConnectionAttributes.accountId == accountViewModel.id {
            
            accountConnectionId = accountConnectionAttributes.id
        }
        
        accountConnectionAttributes =
            AccountConnectionNestedAttributes(id: accountConnectionId,
                                              accountId: accountViewModel.id,
                                              shouldDestroy: nil)
    }
    
    func removeAccountConnection() {
        accountConnectionAttributes?.id = expenseSource?.accountConnection?.id
        accountConnectionAttributes?.shouldDestroy = true
        selectedIconURL = nil
    }
}
