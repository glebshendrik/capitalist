//
//  ExpenseSourceEditViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseSourceUpdatingError : Error {
    case updatingExpenseSourceIsNotSpecified
}

class ExpenseSourceEditViewModel : TransactionableExamplesDependantProtocol {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol    
    var transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    
    private var expenseSource: ExpenseSource? = nil
    
    let bankConnectableViewModel: BankConnectableViewModel
    
    var selectedIconURL: URL? = nil
    var selectedCurrency: Currency? = nil
    var selectedCardType: CardType? = nil
    var name: String? = nil
    var amount: String? = nil
    var creditLimit: String? = nil
    
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
    
    var connectionConnected: Bool {
        return bankConnectableViewModel.connectionConnected
    }
        
    var iconType: IconType {
        return selectedIconURL?.iconType ?? .raster
    }
    
    // Permissions
    
    var canChangeIcon: Bool {
        return !connectionConnected && !connectable
    }
    
    var canChangeCurrency: Bool {
        return !(expenseSource?.hasTransactions ?? false) && !bankConnectableViewModel.accountConnected
    }
    
    var canChangeAmount: Bool {
        return !connectionConnected
    }
    
    var canChangeCreditLimit: Bool {
        return !connectionConnected
    }
    
    var canChangeCardType: Bool {
        return !connectionConnected
    }
        
    // Visibility
        
    var iconPenHidden: Bool {
        return !canChangeIcon
    }
        
    var bankButtonHidden: Bool {
        return connectionConnected || !(isNew && connectable)
    }
                    
    var removeButtonHidden: Bool {
        return isNew
    }
        
    var bankButtonTitle: String {
        return NSLocalizedString("Подключить банк", comment: "Подключить банк")
    }
    
    var currentUser: User? = nil
    
    var numberOfUnusedExamples: Int = 0
    
    var basketType: BasketType = .joy
    
    var example: TransactionableExampleViewModel? = nil
    
    var transactionableType: TransactionableType {
        return .expenseSource
    }
    
    var shouldSkipExamplesPrompt: Bool = false
    
    var providerCodes: [String]? {
        return bankConnectableViewModel.providerCodes ?? example?.providerCodes
    }
    
    var prototypeKey: String? {
        return bankConnectableViewModel.prototypeKey ?? example?.prototypeKey
    }
    
    var connectable: Bool {
        return !(prototypeKey != nil && providerCodes == nil)
    }
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        self.bankConnectableViewModel = BankConnectableViewModel(bankConnectionsCoordinator: bankConnectionsCoordinator,
                                                                 expenseSourcesCoordinator: expenseSourcesCoordinator,
                                                                 accountCoordinator: accountCoordinator)
    }
    
//    func loadProvider() -> Promise<ProviderViewModel?> {
//        guard
//            let providerCodes = providerCodes,
//            providerCodes.count == 1,
//            let code = providerCodes.first
//        else {
//            return Promise.value(nil)
//        }
//        return
//            firstly {
//                bankConnectionsCoordinator.loadProvider(code: code)
//            }.then { provider -> Promise<ProviderViewModel?> in
//                return Promise.value(ProviderViewModel(provider: provider))
//            }
//    }
    
    func loadData() -> Promise<Void> {
        return isNew
            ? when(fulfilled: loadDefaultCurrency(), loadExamples())
            : loadExpenseSource()
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                    self.currentUser = user
                }
    }
    
    func loadExpenseSource() -> Promise<Void> {
        guard
            let expenseSourceId = expenseSource?.id
        else {
            return Promise.value(())
        }
        return
            firstly {
                expenseSourcesCoordinator.show(by: expenseSourceId)
            }.get {
                self.set(expenseSource: $0)
            }.asVoid()
    }
    
    func set(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        
        selectedIconURL = expenseSource.accountConnection?.connection.providerLogoURL ?? expenseSource.iconURL
        selectedCurrency = expenseSource.currency
        selectedCardType = expenseSource.cardType
        name = expenseSource.name
        amount = expenseSource.amountCents.moneyDecimalString(with: selectedCurrency)
        creditLimit = expenseSource.creditLimitCents?.moneyDecimalString(with: selectedCurrency)
        bankConnectableViewModel.set(expenseSource: ExpenseSourceViewModel(expenseSource: expenseSource))
    }
    
    func set(example: TransactionableExampleViewModel) {
        self.example = example
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
        return
            firstly {
                expenseSourcesCoordinator.create(with: creationForm())
            }.get {
                self.set(expenseSource: $0)
            }.asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ExpenseSourceCreationForm {
        let amountCents = bankConnectableViewModel.accountViewModel?.amountCents ?? amountToSave.intMoney(with: selectedCurrency)
        let creditLimitCents = bankConnectableViewModel.accountViewModel?.creditLimitCents ?? creditLimitToSave.intMoney(with: selectedCurrency)
        let cardType = bankConnectableViewModel.accountViewModel?.cardType ?? selectedCardType
        selectedIconURL = bankConnectableViewModel.connection?.providerLogoURL ?? selectedIconURL
        name = bankConnectableViewModel.accountViewModel?.name ?? bankConnectableViewModel.connection?.providerName ?? name
        return ExpenseSourceCreationForm(userId: accountCoordinator.currentSession?.userId,
                                         name: name,
                                         iconURL: selectedIconURL,
                                         currency: selectedCurrency?.code,
                                         amountCents: amountCents,
                                         creditLimitCents: creditLimitCents,
                                         cardType: cardType,
                                         prototypeKey: example?.prototypeKey,
                                         maxFetchInterval: bankConnectableViewModel.providerViewModel?.maxFetchInterval,
                                         accountConnectionAttributes: bankConnectableViewModel.accountConnectionAttributes)
    }
}

// Updating
extension ExpenseSourceEditViewModel {
    private func update() -> Promise<Void> {
        guard
            let expenseSourceId = expenseSource?.id
        else {
            return Promise(error: ExpenseSourceUpdatingError.updatingExpenseSourceIsNotSpecified)
        }
        return
            firstly {
                expenseSourcesCoordinator.update(with: updatingForm())
            }.then {
                self.expenseSourcesCoordinator.show(by: expenseSourceId)
            }.get {
                self.set(expenseSource: $0)
            }.asVoid()
            
    }
    
    private func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> ExpenseSourceUpdatingForm {
        var currencyCode = selectedCurrency?.code
        if bankConnectableViewModel.accountConnected &&
            expenseSource?.currency.code != bankConnectableViewModel.accountViewModel?.currencyCode {
            currencyCode = bankConnectableViewModel.accountViewModel?.currencyCode
        }
        return ExpenseSourceUpdatingForm(id: expenseSource?.id,
                                         name: name,
                                         iconURL: selectedIconURL,
                                         currency: currencyCode,
                                         amountCents: amountToSave.intMoney(with: selectedCurrency),          
                                         creditLimitCents: creditLimitToSave.intMoney(with: selectedCurrency),
                                         cardType: selectedCardType,
                                         accountConnectionAttributes: bankConnectableViewModel.accountConnectionAttributes)
    }
}
