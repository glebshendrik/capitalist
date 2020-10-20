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

class ExpenseSourceInfoViewController : EntityInfoNavigationController, BankConnectionControllerProtocol {
    
    var viewModel: ExpenseSourceInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
    
    var bankConnectionViewModel: BankConnectionViewModel! {
        return viewModel.bankConnectionViewModel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if bankConnectionViewModel.accountConnected {
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
        guard bankConnectionViewModel.canConnectBank else {
            modal(factory.subscriptionNavigationViewController(requiredPlans: [.platinum]))
            return
        }
        guard bankConnectionViewModel.reconnectNeeded else { return }
        setupConnection()
    }
        
    override func showEditScreen() {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: viewModel.expenseSource))
    }
    
    override func didUpdateData() {
        super.didUpdateData()
        showAccounts()
    }
    
    func didTapBankButton() {
        guard bankConnectionViewModel.canConnectBank else {
            modal(factory.subscriptionNavigationViewController(requiredPlans: [.platinum]))
            return
        }
        if bankConnectionViewModel.connectionConnected {
            disconnectAccount()
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

extension ExpenseSourceInfoViewController : Navigatable, Updatable {
    var viewController: Infrastructure.ViewController {
        return Infrastructure.ViewController.ExpenseSourceInfoViewController
    }
    
    var presentingCategories: [NotificationCategory] {
        return [NotificationCategory.saltedgeNotification(expenseSourceId: viewModel.expenseSource?.id)]
    }
    
    func navigate(to viewController: Infrastructure.ViewController, with category: NotificationCategory) {
        
    }
    
    func update() {
        refreshData()
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
