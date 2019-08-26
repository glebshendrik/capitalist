//
//  EditableCellDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : EditableCellDelegate {
    func didTapDeleteButton(cell: EditableCellProtocol) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let incomeSourceId = (cell as? IncomeSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить источник доходов?"
            removeAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: true)
            }
        }
        if let expenseSourceId = (cell as? ExpenseSourceCollectionViewCell)?.viewModel?.id {
            alertTitle = "Удалить кошелек?"
            removeAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: true)
            }
        }
        if let expenseCategoryViewModel = (cell as? ExpenseCategoryCollectionViewCell)?.viewModel {
            alertTitle = "Удалить категорию трат?"
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
        
        let alertController = UIAlertController(title: alertTitle,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: removeAction)
        
        alertController.addAction(title: "Удалить вместе с транзакциями",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: removeWithTransactionsAction)
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    func didTapEditButton(cell: EditableCellProtocol) {
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
    }
}
