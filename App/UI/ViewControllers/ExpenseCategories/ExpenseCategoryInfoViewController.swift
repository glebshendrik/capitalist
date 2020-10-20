//
//  ExpenseCategoryInfoViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ExpenseCategoryInfoViewController : EntityInfoNavigationController {
    var viewModel: ExpenseCategoryInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        modal(factory.iconsViewController(delegate: self, iconCategory: viewModel.basketType.iconCategory))
    }
        
    override func didTapReminderButton(field: ReminderInfoField?) {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminder))
    }
        
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ExpenseCategoryInfoField.statistics.identifier:
            modal(factory.statisticsModalViewController(filter: viewModel.asFilter()))
        case ExpenseCategoryInfoField.transaction.identifier:
            didTapTransactionButton()
        default:
            return
        }
    }
    
    private func didTapTransactionButton() {
        if viewModel.isBorrow {
            modal(factory.borrowEditViewController(delegate: self, type: .debt, borrowId: nil, source: nil, destination: viewModel.expenseCategoryViewModel))
        }
        else {
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel.expenseCategoryViewModel, transactionType: .expense))
        }
        
    }
    
    override func showEditScreen() {
        modal(factory.expenseCategoryEditViewController(delegate: self, expenseCategory: viewModel.expenseCategory, basketType: viewModel.basketType))
    }
    
    override func didCreateDebt() {
        refreshData()
    }
    
    override func didCreateLoan() {
        refreshData()
    }
    
    override func didUpdateDebt() {
        refreshData()
    }
    
    override func didUpdateLoan() {
        refreshData()
    }
    
    override func didRemoveDebt() {
        refreshData()
    }
    
    override func didRemoveLoan() {
        refreshData()
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

extension ExpenseCategoryInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension ExpenseCategoryInfoViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminder = reminderViewModel
        save()
    }
}

extension ExpenseCategoryInfoViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        refreshData()
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
}
