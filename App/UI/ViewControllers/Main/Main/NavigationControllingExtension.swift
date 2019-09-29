//
//  NavigationControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func showStatistics(with filterViewModel: SourceOrDestinationHistoryTransactionFilter) {
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
    func showTransactionEditScreen(transactionStartable: TransactionStartable, transactionCompletable: TransactionCompletable) {
        soundsManager.playTransactionStartedSound()
        switch (transactionStartable, transactionCompletable) {
        case (let startable as IncomeSourceViewModel, let completable as ExpenseSourceViewModel):
            showIncomeEditScreen(incomeSourceStartable: startable, expenseSourceCompletable: completable)
        case (let startable as ExpenseSourceViewModel, let completable as ExpenseSourceViewModel):
            showFundsMoveEditScreen(expenseSourceStartable: startable, expenseSourceCompletable: completable)
        case (let startable as ExpenseSourceViewModel, let completable as ExpenseCategoryViewModel):
            showExpenseEditScreen(expenseSourceStartable: startable, expenseCategoryCompletable: completable)
        default:
            return
        }
    }
    
    private func showIncomeEditScreen(incomeSourceStartable: IncomeSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        if  let incomeEditNavigationController = router.viewController(.IncomeEditNavigationController) as? UINavigationController,
            let incomeEditViewController = incomeEditNavigationController.topViewController as? IncomeEditViewController {
            
            incomeEditViewController.set(delegate: self)
            
            incomeEditViewController.set(startable: incomeSourceStartable, completable: expenseSourceCompletable)
            
            present(incomeEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        
        if expenseSourceStartable.hasWaitingDebts {
            showBorrowsSheet(notReturnTitle: "Занять",
                           returnTitle: "Возвращение долга",
                           waitingBorrows: expenseSourceStartable.waitingDebts,
                           expenseSourceStartable: expenseSourceStartable,
                           expenseSourceCompletable: expenseSourceCompletable,
                           borrowType: .debt)
        } else if expenseSourceCompletable.hasWaitingLoans {
            showBorrowsSheet(notReturnTitle: "Одолжить",
                           returnTitle: "Возвращение займа",
                           waitingBorrows: expenseSourceCompletable.waitingLoans,
                           expenseSourceStartable: expenseSourceStartable,
                           expenseSourceCompletable: expenseSourceCompletable,
                           borrowType: .loan)
        } else {
            showBorrowOrFundsMove(expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable)
        }
    }
    
    private func showBorrowOrFundsMove(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        if expenseSourceStartable.isDebt || expenseSourceCompletable.isDebt {
            showBorrowEditScreen(expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable)
        } else {
            showFundsMoveEditScreen(expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable, borrow: nil)
        }
    }
    
    private func showBorrowsSheet(notReturnTitle: String, returnTitle: String, waitingBorrows: [BorrowViewModel], expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel, borrowType: BorrowType) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(title: notReturnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    self.showBorrowOrFundsMove(expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable)
        }
        
        alertController.addAction(title: returnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    
                                    self.show(waitingBorrows: waitingBorrows,
                                              expenseSourceStartable: expenseSourceStartable,
                                              expenseSourceCompletable: expenseSourceCompletable,
                                              borrowType: borrowType)
        }
        
        alertController.addAction(title: "Отмена", style: .cancel, isEnabled: true, handler: nil)
        
        present(alertController, animated: true)
    }
    
    private func show(waitingBorrows: [BorrowViewModel], expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel, borrowType: BorrowType) {
        
        if let waitingBorrowsViewController = router.viewController(.WaitingBorrowsViewController) as? WaitingBorrowsViewController {
            
            waitingBorrowsViewController.set(delegate: self, expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable, waitingBorrows: waitingBorrows, borrowType: borrowType)
            
            slideUp(viewController: waitingBorrowsViewController)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel, borrow: BorrowViewModel?) {
        modal(factory.fundsMoveEditViewController(delegate: self,
                                                  startable: expenseSourceStartable,
                                                  completable: expenseSourceCompletable,
                                                  borrow: borrow))
    }
    
    private func showBorrowEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        let type = expenseSourceStartable.isDebt ? BorrowType.loan : BorrowType.debt
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               expenseSourceFrom: expenseSourceStartable,
                                               expenseSourceTo: expenseSourceCompletable))
    }
    
    private func showExpenseEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseCategoryCompletable: ExpenseCategoryViewModel) {
        if  let expenseEditNavigationController = router.viewController(.ExpenseEditNavigationController) as? UINavigationController,
            let expenseEditViewController = expenseEditNavigationController.topViewController as? ExpenseEditViewController {
            
            expenseEditViewController.set(delegate: self)
            
            expenseEditViewController.set(startable: expenseSourceStartable, completable: expenseCategoryCompletable)
            
            present(expenseEditNavigationController, animated: true, completion: nil)
        }
    }
}

extension MainViewController : WaitingBorrowsViewControllerDelegate {
    func didSelect(borrow: BorrowViewModel, expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        showFundsMoveEditScreen(expenseSourceStartable: expenseSourceStartable, expenseSourceCompletable: expenseSourceCompletable, borrow: borrow)
    }
}
