//
//  ExpenseSourceInfoViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyBeaver

class ExpenseSourceInfoViewController : EntityInfoNavigationController, BankConnectableProtocol {
    
    var viewModel: ExpenseSourceInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
    
    var bankConnectableViewModel: BankConnectableViewModel! {
        return viewModel.bankConnectableViewModel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if bankConnectableViewModel.accountConnected {
            refreshData()
        }        
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
    
    override func didTapConnectBankButton(field: BankConnectionInfoField) {
        connectTo(providerCodes: viewModel.expenseSourceViewModel?.providerCodes)
    }
    
    override func didTapDisconnectBankButton(field: BankConnectionInfoField) {
        disconnectAccount()
    }
    
    override func didTapReconnectBankButton(field: BankConnectionInfoField) {
        setupConnection()
    }
    
    override func didTapSendInteractiveFieldsButton(field: BankConnectionInfoField) {
        sendInteractiveCredentials()
    }
    
    override func showEditScreen() {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: viewModel.expenseSource, shouldSkipExamplesPrompt: false))
    }
    
    override func didUpdateData() {
        super.didUpdateData()
        showAccounts()
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
    
    override var viewController: Infrastructure.ViewController {
        return Infrastructure.ViewController.ExpenseSourceInfoViewController
    }
    
    override var presentingCategories: [NotificationCategory] {
        return [NotificationCategory.saltedgeNotification(expenseSourceId: viewModel.expenseSource?.id)]
    }
    
    override func navigate(to viewController: Infrastructure.ViewController, with category: NotificationCategory) {
        
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
