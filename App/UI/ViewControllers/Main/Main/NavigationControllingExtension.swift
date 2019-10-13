//
//  NavigationControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func showStatistics(with filterViewModel: SourceOrDestinationTransactionFilter) {
        if  let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController {
            
            statisticsViewController.set(sourceOrDestinationFilter: filterViewModel)
            
            navigationController?.pushViewController(statisticsViewController)
        }
    }
}

extension MainViewController {
    func showBalance() {
        if  let balanceViewController = router.viewController(.BalanceViewController) as? BalanceViewController {            
            navigationController?.pushViewController(balanceViewController)
        }
    }
}

extension MainViewController {
    func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        if  let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditViewController {
            
            incomeSourceEditViewController.set(delegate: self)
            
            if let incomeSource = incomeSource {
                incomeSourceEditViewController.set(incomeSource: incomeSource)
            }
            
            present(incomeSourceEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension MainViewController {
    func showNewExpenseSourceScreen() {
        showEditScreen(expenseSource: nil)
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        if  let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController,
            let expenseSourceEditViewController = expenseSourceEditNavigationController.topViewController as? ExpenseSourceEditViewController {
            
            expenseSourceEditViewController.set(delegate: self)
            
            if let expenseSource = expenseSource {
                expenseSourceEditViewController.set(expenseSource: expenseSource)
            }
            
            present(expenseSourceEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension MainViewController {
    func showNewExpenseCategoryScreen(basketType: BasketType) {
        showEditScreen(expenseCategory: nil, basketType: basketType)
    }
    
    func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        if let creditId = expenseCategory?.creditId {
            showCreditEditScreen(creditId: creditId)
        } else {
            showExpenseCategoryEditScreen(expenseCategory: expenseCategory, basketType: basketType)
        }
    }
    
    func showExpenseCategoryEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        if  let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController,
            let expenseCategoryEditViewController = expenseCategoryEditNavigationController.topViewController as? ExpenseCategoryEditViewController {
            
            expenseCategoryEditViewController.set(delegate: self)
            expenseCategoryEditViewController.set(basketType: basketType)
            
            if let expenseCategory = expenseCategory {
                expenseCategoryEditViewController.set(expenseCategory: expenseCategory)
            }
            
            present(expenseCategoryEditNavigationController, animated: true, completion: nil)
        }
    }
    
    func showCreditEditScreen(creditId: Int) {
        modal(factory.creditEditViewController(delegate: self, creditId: creditId))
    }
}

extension MainViewController {
    func showTransactionEditScreen(transactionSource: TransactionSource, transactionDestination: TransactionDestination) {
        soundsManager.playTransactionStartedSound()
        switch (transactionSource, transactionDestination) {
        case (let source as IncomeSourceViewModel, let destination as ExpenseSourceViewModel):
            showIncomeEditScreen(incomeSourceSource: source, expenseSourceDestination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseSourceViewModel):
            showFundsMoveEditScreen(expenseSourceSource: source, expenseSourceDestination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseCategoryViewModel):
            showExpenseEditScreen(expenseSourceSource: source, expenseCategoryDestination: destination)
        default:
            return
        }
    }
    
    private func showIncomeEditScreen(incomeSourceSource: IncomeSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel) {
        if  let incomeEditNavigationController = router.viewController(.IncomeEditNavigationController) as? UINavigationController,
            let incomeEditViewController = incomeEditNavigationController.topViewController as? IncomeEditViewController {
            
            incomeEditViewController.set(delegate: self)
            
            incomeEditViewController.set(source: incomeSourceSource, destination: expenseSourceDestination)
            
            present(incomeEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel) {
        
        if expenseSourceSource.hasWaitingDebts {
            showBorrowsSheet(notReturnTitle: "Занять",
                           returnTitle: "Возвращение долга",
                           waitingBorrows: expenseSourceSource.waitingDebts,
                           expenseSourceSource: expenseSourceSource,
                           expenseSourceDestination: expenseSourceDestination,
                           borrowType: .debt)
        } else if expenseSourceDestination.hasWaitingLoans {
            showBorrowsSheet(notReturnTitle: "Одолжить",
                           returnTitle: "Возвращение займа",
                           waitingBorrows: expenseSourceDestination.waitingLoans,
                           expenseSourceSource: expenseSourceSource,
                           expenseSourceDestination: expenseSourceDestination,
                           borrowType: .loan)
        } else {
            showBorrowOrFundsMove(expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination)
        }
    }
    
    private func showBorrowOrFundsMove(expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel) {
        if expenseSourceSource.isDebt || expenseSourceDestination.isDebt {
            showBorrowEditScreen(expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination)
        } else {
            showFundsMoveEditScreen(expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination, borrow: nil)
        }
    }
    
    private func showBorrowsSheet(notReturnTitle: String, returnTitle: String, waitingBorrows: [BorrowViewModel], expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel, borrowType: BorrowType) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(title: notReturnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    self.showBorrowOrFundsMove(expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination)
        }
        
        alertController.addAction(title: returnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    
                                    self.show(waitingBorrows: waitingBorrows,
                                              expenseSourceSource: expenseSourceSource,
                                              expenseSourceDestination: expenseSourceDestination,
                                              borrowType: borrowType)
        }
        
        alertController.addAction(title: "Отмена", style: .cancel, isEnabled: true, handler: nil)
        
        present(alertController, animated: true)
    }
    
    private func show(waitingBorrows: [BorrowViewModel], expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel, borrowType: BorrowType) {
        
        if let waitingBorrowsViewController = router.viewController(.WaitingBorrowsViewController) as? WaitingBorrowsViewController {
            
            waitingBorrowsViewController.set(delegate: self, expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination, waitingBorrows: waitingBorrows, borrowType: borrowType)
            
            slideUp(viewController: waitingBorrowsViewController)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel, borrow: BorrowViewModel?) {
        modal(factory.fundsMoveEditViewController(delegate: self,
                                                  source: expenseSourceSource,
                                                  destination: expenseSourceDestination,
                                                  borrow: borrow))
    }
    
    private func showBorrowEditScreen(expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel) {
        let type = expenseSourceSource.isDebt ? BorrowType.loan : BorrowType.debt
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               expenseSourceFrom: expenseSourceSource,
                                               expenseSourceTo: expenseSourceDestination))
    }
    
    private func showExpenseEditScreen(expenseSourceSource: ExpenseSourceViewModel, expenseCategoryDestination: ExpenseCategoryViewModel) {
        if  let expenseEditNavigationController = router.viewController(.ExpenseEditNavigationController) as? UINavigationController,
            let expenseEditViewController = expenseEditNavigationController.topViewController as? ExpenseEditViewController {
            
            expenseEditViewController.set(delegate: self)
            
            expenseEditViewController.set(source: expenseSourceSource, destination: expenseCategoryDestination)
            
            present(expenseEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension MainViewController : WaitingBorrowsViewControllerDelegate {
    func didSelect(borrow: BorrowViewModel, expenseSourceSource: ExpenseSourceViewModel, expenseSourceDestination: ExpenseSourceViewModel) {
        showFundsMoveEditScreen(expenseSourceSource: expenseSourceSource, expenseSourceDestination: expenseSourceDestination, borrow: borrow)
    }
}
