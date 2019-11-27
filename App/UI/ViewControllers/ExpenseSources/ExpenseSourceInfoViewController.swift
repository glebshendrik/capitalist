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
                
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ExpenseSourceInfoField.statistics.identifier:
            modal(factory.statisticsModalViewController(filter: viewModel.asFilter()))
        case ExpenseSourceInfoField.transactionIncome.identifier:        
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.expenseSourceViewModel))
        case ExpenseSourceInfoField.transactionExpense.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.expenseSourceViewModel, destination: nil))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: viewModel.expenseSource))
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
        closeButtonHandler()
    }
}

extension ExpenseSourceInfoViewController : TransactionEditViewControllerDelegate {
    func didCreateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
}
