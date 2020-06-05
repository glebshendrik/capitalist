//
//  ExpenseSourceInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ExpenseSourceInfoViewController : EntityInfoNavigationController {
    var viewModel: ExpenseSourceInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
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

extension ExpenseSourceInfoViewController : ProvidersViewControllerDelegate, AccountsViewControllerDelegate {
    func showProviders() {
        guard let providersViewController = factory.providersViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: providersViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, connection: Connection) {
        showAccountsViewController(for: connection)
    }
    
    func showAccountsViewController(for connection: Connection) {
        let currencyCode = viewModel.expenseSourceViewModel?.currency.code
        slideUp(factory.accountsViewController(delegate: self,
                                               connection: connection,
                                               currencyCode: currencyCode))
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
