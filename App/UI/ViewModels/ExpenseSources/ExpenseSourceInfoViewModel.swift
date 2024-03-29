//
//  ExpenseSourceInfoViewModel.swift
//  Capitalist
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
    case bankConnection
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
    
    let bankConnectableViewModel: BankConnectableViewModel
    var expenseSourceViewModel: ExpenseSourceViewModel?
    
    var expenseSource: ExpenseSource? {
        return expenseSourceViewModel?.expenseSource
    }
    
    override var transactionable: Transactionable? {
        return expenseSourceViewModel
    }
    
    var selectedIconURL: URL? = nil
    
    var iconType: IconType {
        return expenseSourceViewModel?.iconType ?? .raster
    }
    
    var canEditIcon: Bool {
        return !bankConnectableViewModel.connectionConnected && !bankConnectableViewModel.connectable
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        self.bankConnectableViewModel = BankConnectableViewModel(bankConnectionsCoordinator: bankConnectionsCoordinator,
                                                               expenseSourcesCoordinator: expenseSourcesCoordinator,
                                                               accountCoordinator: accountCoordinator)
        super.init(transactionsCoordinator: transactionsCoordinator,
                   creditsCoordinator: creditsCoordinator,
                   borrowsCoordinator: borrowsCoordinator,
                   accountCoordinator: accountCoordinator)
    }
    
    func set(expenseSource: ExpenseSourceViewModel?) {
        self.expenseSourceViewModel = expenseSource
        self.selectedIconURL = expenseSource?.iconURL
        self.bankConnectableViewModel.set(expenseSource: expenseSource)
    }
    
    override func loadEntity() -> Promise<Void> {
        guard
            let entityId = expenseSourceViewModel?.id
        else {
            return Promise(error: ExpenseSourceInfoError.expenseSourceIsNotSpecified)
        }
        return
            firstly {
                expenseSourcesCoordinator.show(by: entityId)
            }.then { expenseSource -> Promise<ExpenseSource> in
                return self.loadProvider(expenseSource: expenseSource)
            }.done { expenseSource in
                self.set(expenseSource: ExpenseSourceViewModel(expenseSource: expenseSource))
            }
    }
    
    func loadProvider(expenseSource: ExpenseSource) -> Promise<ExpenseSource> {
        guard
            let connection = expenseSource.accountConnection?.connection
        else {
            return Promise.value(expenseSource)
        }
        return
            firstly {
                bankConnectableViewModel.connectionWithProvider(connection)
            }.then { connection -> Promise<ExpenseSource> in
                return Promise.value(expenseSource)
            }
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        var fields = [EntityInfoField]()
        
        fields.append(IconInfoField(fieldId: ExpenseSourceInfoField.icon.rawValue,
                                    iconType: iconType,
                                    iconURL: selectedIconURL,
                                    placeholder: TransactionableType.expenseSource.defaultIconName,
                                    canEditIcon: canEditIcon))
        
        fields.append(BankConnectionInfoField(fieldId: ExpenseSourceInfoField.bankConnection.rawValue,
                                              bankConnectableViewModel: bankConnectableViewModel))
        
        fields.append(BasicInfoField(fieldId: ExpenseSourceInfoField.balance.rawValue,
                                     title: NSLocalizedString("Баланс", comment: "Баланс"),
                                     value: expenseSourceViewModel?.amount))
        
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
        
        fields.append(ButtonInfoField(fieldId: ExpenseSourceInfoField.statistics.rawValue,
                                      title: NSLocalizedString("Статистика", comment: "Статистика"),
                                      iconName: nil,
                                      isEnabled: true))
        
        if !bankConnectableViewModel.connectionConnected {
            fields.append(contentsOf: [ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionIncome.rawValue,
                                                       title: NSLocalizedString("Добавить доход", comment: "Добавить доход"),
                                                       iconName: nil,
                                                       isEnabled: true),
                                       ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionExpense.rawValue,
                                                       title: NSLocalizedString("Добавить расход", comment: "Добавить расход"),
                                                       iconName: nil,
                                                       isEnabled: true)])
        }
        
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return expenseSourcesCoordinator.update(with: updateForm())
    }
         
    private func updateForm() -> ExpenseSourceUpdatingForm {
        let amountCents = bankConnectableViewModel.accountViewModel?.amountCents ?? expenseSourceViewModel?.expenseSource.amountCents
        let creditLimitCents = bankConnectableViewModel.accountViewModel?.creditLimitCents ?? expenseSourceViewModel?.expenseSource.creditLimitCents
        let cardType = bankConnectableViewModel.accountViewModel?.cardType ?? expenseSourceViewModel?.expenseSource.cardType
        selectedIconURL = bankConnectableViewModel.connection?.providerLogoURL ?? expenseSourceViewModel?.expenseSource.iconURL
        let currencyCode = bankConnectableViewModel.accountViewModel?.currencyCode ?? expenseSourceViewModel?.currency.code
        return ExpenseSourceUpdatingForm(id: expenseSourceViewModel?.id,
                                         name: expenseSourceViewModel?.name,
                                         iconURL: selectedIconURL,
                                         currency: currencyCode,
                                         amountCents: amountCents,
                                         creditLimitCents: creditLimitCents,
                                         cardType: cardType,
                                         prototypeKey: bankConnectableViewModel.prototypeKey,
                                         accountConnectionAttributes: bankConnectableViewModel.accountConnectionAttributes)
    }
}

// Bank Connection

//extension ExpenseSourceInfoViewModel : SEConnectionFetchingDelegate {
//    func failedToFetch(connection: SEConnection?, message: String) {
//        SwiftyBeaver.error(message)
//    }
//
//    func interactiveInputRequested(for connection: SEConnection) {
//        SwiftyBeaver.info("interactiveInputRequested: \(connection)")
//    }
//
//    func successfullyFinishedFetching(connection: SEConnection) {
//        SwiftyBeaver.info("successfullyFinishedFetching: \(connection)")
//    }
//}
