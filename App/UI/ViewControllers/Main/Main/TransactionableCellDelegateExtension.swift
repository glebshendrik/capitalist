//
//  EditableCellDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : TransactionableCellDelegate {
    func canDelete(cell: TransactionableCellProtocol) -> Bool {
        return true
    }
    
    func canSelect(cell: TransactionableCellProtocol) -> Bool {
        return true
    }
    
    func didTapDeleteButton(cell: TransactionableCellProtocol) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let incomeSourceId = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = TransactionableType.incomeSource.removeQuestion
            removeAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: true)
            }
        }
        if let expenseSourceId = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = TransactionableType.expenseSource.removeQuestion
            removeAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: true)
            }
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            alertTitle = TransactionableType.expenseCategory.removeQuestion
            removeAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryViewModel.id,
                                           basketType: expenseCategoryViewModel.expenseCategory.basketType,
                                           deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryViewModel.id,
                                           basketType: expenseCategoryViewModel.expenseCategory.basketType,
                                           deleteTransactions: true)
            }
        }
        if let activeViewModel = (cell as? ActiveCollectionViewCell)?.viewModel {
            alertTitle = TransactionableType.active.removeQuestion
            removeAction = { _ in
                self.removeActive(by: activeViewModel.id,
                                  basketType: activeViewModel.basketType,
                                  deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeActive(by: activeViewModel.id,
                                  basketType: activeViewModel.basketType,
                                  deleteTransactions: true)
            }
        }
        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                                      style: .destructive,
                                                      handler: removeAction),
                                        UIAlertAction(title: NSLocalizedString("Удалить вместе с транзакциями", comment: "Удалить вместе с транзакциями"),
                                                      style: .destructive,
                                                      handler: removeWithTransactionsAction)]
        sheet(title: alertTitle, actions: actions)
    }
    
    func didTapEditButton(cell: TransactionableCellProtocol) {
        if let incomeSource = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.incomeSource {
            showEditScreen(incomeSource: incomeSource)
        }
        if let expenseSource = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.expenseSource {
            showEditScreen(expenseSource: expenseSource)
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            showEditScreen(expenseCategory: expenseCategoryViewModel.expenseCategory,
                           basketType: expenseCategoryViewModel.expenseCategory.basketType)
        }
        if let activeViewModel = (cell as? ActiveCollectionViewCell)?.viewModel {
            showActiveEditScreen(active: activeViewModel.active,
                                 basketType: activeViewModel.basketType)
        }
    }
}
