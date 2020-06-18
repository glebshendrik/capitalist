//
//  ExpenseSourceInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyBeaver

class ExpenseSourceInfoViewController : EntityInfoNavigationController {
    var viewModel: ExpenseSourceInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        guard viewModel.canEditIcon else { return }
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.expenseSource))
    }
         
    override func didTapInfoField(field: BasicInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ExpenseSourceInfoField.balance.identifier:
            showEditScreen()
        default:
            return
        }
    }
    
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ExpenseSourceInfoField.bank.identifier:
            didTapBankButton()
        case ExpenseSourceInfoField.statistics.identifier:
            modal(factory.statisticsModalViewController(filter: viewModel.asFilter()))
        case ExpenseSourceInfoField.transactionIncome.identifier:        
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.expenseSourceViewModel, transactionType: .income))
        case ExpenseSourceInfoField.transactionExpense.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.expenseSourceViewModel, destination: nil, transactionType: .expense))
        default:
            return
        }
    }
    
    override func didTapBankWarningInfoButton(field: BankWarningInfoField?) {
        guard viewModel.reconnectNeeded else { return }
        showConnectionSession()
    }
        
    override func showEditScreen() {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: viewModel.expenseSource))
    }
    
    func didTapBankButton() {
        if viewModel.accountConnected {
            removeAccountConnection()
        } else {
            showProviders()
        }
    }
    
    override var isSelectingTransactionables: Bool {
        return false
    }
    
    override func didCreateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    override func didUpdateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    override func didRemoveTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
}

extension ExpenseSourceInfoViewController : ConnectionViewControllerDelegate {
    func showConnectionSession() {
        messagePresenterManager.showHUD(with: NSLocalizedString("Подготовка подключения к банку...", comment: "Подготовка подключения к банку..."))
        
        firstly {
            viewModel.reconnectSessionURL()
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connectionURL in
            self.showConnectionViewController(connectionURL: connectionURL)
        }.catch { e in
            print(e)
            SwiftyBeaver.error(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
    
    func showConnectionViewController(connectionURL: URL) {
        
        guard let connectionViewController = factory.connectionViewController(delegate: self,
                                                                              providerViewModel: nil,
                                                                              connectionType: viewModel.reconnectType,
                                                                              connectionURL: connectionURL,
                                                                              connection: viewModel.connection) else { return }
        modal(UINavigationController(rootViewController: connectionViewController))
    }
        
    func didConnectToConnection(_ providerViewModel: ProviderViewModel?, connection: Connection) {
        
        refreshData()
    }
        
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
    
    func didNotConnect(error: Error) {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
}

extension ExpenseSourceInfoViewController : ProvidersViewControllerDelegate, AccountsViewControllerDelegate {
    func showProviders() {
        guard let providersViewController = factory.providersViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: providersViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel?, connection: Connection) {
        showAccountsViewController(for: connection)
    }
    
    func showAccountsViewController(for connection: Connection) {
        let currencyCode = viewModel.expenseSourceViewModel?.currency.code
        slideUp(factory.accountsViewController(delegate: self,
                                               connection: connection,
                                               currencyCode: currencyCode,
                                               nature: .account))
    }
    
    func didSelect(accountViewModel: AccountViewModel, connection: Connection) {
        connect(accountViewModel, connection)
    }
    
    func connect(_ accountViewModel: AccountViewModel, _ connection: Connection) {
        viewModel.connect(accountViewModel: accountViewModel, connection: connection)
        save()
    }
    
    func removeAccountConnection() {
        viewModel.removeAccountConnection()
        save()
    }
}

extension ExpenseSourceInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension ExpenseSourceInfoViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        
    }
    
    func didUpdateExpenseSource() {
        refreshData()
    }
    
    func didRemoveExpenseSource() {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
}
