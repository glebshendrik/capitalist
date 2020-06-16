//
//  ExpenseSourceInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge
import SwiftyBeaver

enum ExpenseSourceInfoField : String {
    case icon
    case balance
    case creditLimit
    case credit
    case bank
    case statistics
    case transactionIncome
    case transactionExpense
    
    var identifier: String {
        return rawValue
    }
}

enum ExpenseSourceInfoError : Error {
    case expenseSourceIsNotSpecified
}

class ExpenseSourceInfoViewModel : EntityInfoViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    var expenseSourceViewModel: ExpenseSourceViewModel?
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    var selectedIconURL: URL? = nil
    var selectedAccountViewModel: AccountViewModel? = nil
    
    var expenseSource: ExpenseSource? {
        return expenseSourceViewModel?.expenseSource
    }
    
    override var transactionable: Transactionable? {
        return expenseSourceViewModel
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
    
    var iconType: IconType {
        return expenseSourceViewModel?.iconType ?? .raster
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, creditsCoordinator: creditsCoordinator, borrowsCoordinator: borrowsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(expenseSource: ExpenseSourceViewModel?) {
        self.expenseSourceViewModel = expenseSource
        self.selectedIconURL = expenseSource?.iconURL
        self.selectedAccountViewModel = nil
        if let accountConnection = expenseSource?.expenseSource.accountConnection {
            accountConnectionAttributes =
                AccountConnectionNestedAttributes(id: accountConnection.id,
                                                  accountId: accountConnection.account.id,
                                                  shouldDestroy: nil)
        }
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = expenseSourceViewModel?.id else { return Promise(error: ExpenseSourceInfoError.expenseSourceIsNotSpecified)}
        return  firstly {
                    expenseSourcesCoordinator.show(by: entityId)
                }.done { expenseSource in
                    self.set(expenseSource: ExpenseSourceViewModel(expenseSource: expenseSource))
                }
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        var fields: [EntityInfoField] = [IconInfoField(fieldId: ExpenseSourceInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: TransactionableType.expenseSource.defaultIconName),
                                         BasicInfoField(fieldId: ExpenseSourceInfoField.balance.rawValue,
                                                        title: NSLocalizedString("Баланс", comment: "Баланс"),
                                                        value: expenseSourceViewModel?.amount)]
        if let expenseSourceViewModel = expenseSourceViewModel, expenseSourceViewModel.hasCreditLimit {
            fields.append(BasicInfoField(fieldId: ExpenseSourceInfoField.creditLimit.rawValue,
                                         title: NSLocalizedString("Кредитный лимит", comment: "Кредитный лимит"),
                                         value: expenseSourceViewModel.creditLimit))
        }
        if let expenseSourceViewModel = expenseSourceViewModel, expenseSourceViewModel.inCredit {
            fields.append(BasicInfoField(fieldId: ExpenseSourceInfoField.credit.rawValue,
                                         title: NSLocalizedString("Ваш кредитный долг", comment: "Ваш кредитный долг"),
                                         value: expenseSourceViewModel.credit))
        }
        
        fields.append(ButtonInfoField(fieldId: ExpenseSourceInfoField.bank.rawValue,
                                      title: bankButtonTitle,
                                      iconName: nil,
                                      isEnabled: true))
        
        
        fields.append(contentsOf: [ButtonInfoField(fieldId: ExpenseSourceInfoField.statistics.rawValue,
                                                   title: NSLocalizedString("Статистика", comment: "Статистика"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionIncome.rawValue,
                                                   title: NSLocalizedString("Добавить доход", comment: "Добавить доход"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionExpense.rawValue,
                                                   title: NSLocalizedString("Добавить расход", comment: "Добавить расход"),
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return expenseSourcesCoordinator.update(with: updateForm())
    }
         
    private func updateForm() -> ExpenseSourceUpdatingForm {
        let amountCents = selectedAccountViewModel?.amountCents ?? expenseSourceViewModel?.expenseSource.amountCents   
        let creditLimitCents = selectedAccountViewModel?.creditLimitCents ?? expenseSourceViewModel?.expenseSource.creditLimitCents

        return ExpenseSourceUpdatingForm(id: expenseSourceViewModel?.id,
                                         name: expenseSourceViewModel?.name,
                                         iconURL: selectedIconURL,
                                         amountCents: amountCents,
                                         creditLimitCents: creditLimitCents,
                                         cardType: expenseSourceViewModel?.expenseSource.cardType,
                                         accountConnectionAttributes: accountConnectionAttributes)
    }
}

// Bank Connection

extension ExpenseSourceInfoViewModel : SEConnectionFetchingDelegate {
    func failedToFetch(connection: SEConnection?, message: String) {
        SwiftyBeaver.error(message)
    }
    
    func interactiveInputRequested(for connection: SEConnection) {
        SwiftyBeaver.info("interactiveInputRequested: \(connection)")
    }
    
    func successfullyFinishedFetching(connection: SEConnection) {
        SwiftyBeaver.info("successfullyFinishedFetching: \(connection)")
    }
    
}

extension ExpenseSourceInfoViewModel {
    func connect(accountViewModel: AccountViewModel, connection: Connection) {
        selectedIconURL = connection.providerLogoURL
        selectedAccountViewModel = accountViewModel
        
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
