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
        push(factory.statisticsViewController(filter: filterViewModel))
    }
}

extension MainViewController {
    func showBalance() {
        push(factory.balanceViewController())
    }
}

extension MainViewController {
    func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
    }
}

extension MainViewController {
    func showNewExpenseSourceScreen() {
        showEditScreen(expenseSource: nil)
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource))
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
        modal(factory.expenseCategoryEditViewController(delegate: self, expenseCategory: expenseCategory, basketType: basketType))
    }
    
    func showCreditEditScreen(creditId: Int) {
        modal(factory.creditEditViewController(delegate: self, creditId: creditId))
    }
}

extension MainViewController {
    func showNewActiveScreen(basketType: BasketType) {
        showActiveEditScreen(active: nil, basketType: basketType)
    }
    
    func showActiveEditScreen(active: Active?, basketType: BasketType) {    
        modal(factory.activeEditViewController(delegate: self, active: active, basketType: basketType))
    }    
}

extension MainViewController {
    func showTransactionEditScreen(transactionSource: TransactionSource, transactionDestination: TransactionDestination) {
        soundsManager.playTransactionStartedSound()
        switch (transactionSource, transactionDestination) {
        case (let source as IncomeSourceViewModel, let destination as ExpenseSourceViewModel):
            showIncomeEditScreen(source: source, destination: destination)
        case (let source as IncomeSourceViewModel, let destination as ActiveViewModel):
            showIncomeEditScreen(source: source, destination: destination)
        case (let source as ActiveViewModel, let destination as ExpenseSourceViewModel):
            showIncomeEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseSourceViewModel):
            showFundsMoveEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseCategoryViewModel):
            showExpenseEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ActiveViewModel):
            showExpenseEditScreen(source: source, destination: destination)
        default:
            return
        }
    }
    
    private func showIncomeEditScreen(source: TransactionSource, destination: TransactionDestination) {
        modal(factory.transactionEditViewController(delegate: self, source: source, destination: destination))
    }
    
    private func showFundsMoveEditScreen(source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel) {
        
        if source.hasWaitingDebts {
            showBorrowsSheet(notReturnTitle: "Занять",
                             returnTitle: "Возвращение долга",
                             waitingBorrows: source.waitingDebts,
                             source: source,
                             destination: destination,
                             borrowType: .debt)
        } else if destination.hasWaitingLoans {
            showBorrowsSheet(notReturnTitle: "Одолжить",
                           returnTitle: "Возвращение займа",
                           waitingBorrows: destination.waitingLoans,
                           source: source,
                           destination: destination,
                           borrowType: .loan)
        } else {
            showBorrowOrFundsMove(source: source, destination: destination)
        }
    }
    
    private func showBorrowsSheet(notReturnTitle: String, returnTitle: String, waitingBorrows: [BorrowViewModel], source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel, borrowType: BorrowType) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(title: notReturnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    self.showBorrowOrFundsMove(source: source, destination: destination)
        }
        
        alertController.addAction(title: returnTitle,
                                  style: .default,
                                  isEnabled: true) { _ in
                                    
                                    self.showWaitingBorrows(waitingBorrows,
                                                            source: source,
                                                            destination: destination,
                                                            borrowType: borrowType)
        }
        
        alertController.addAction(title: "Отмена", style: .cancel, isEnabled: true, handler: nil)
        
        present(alertController, animated: true)
    }
    
    private func showBorrowOrFundsMove(source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel) {
        if source.isDebt || destination.isDebt {
            showBorrowEditScreen(source: source, destination: destination)
        } else {
            showFundsMoveEditScreen(source: source, destination: destination, returningBorrow: nil)
        }
    }
    
    private func showWaitingBorrows(_ waitingBorrows: [BorrowViewModel], source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel, borrowType: BorrowType) {
                
        slideUp(viewController: factory.waitingBorrowsViewController(delegate: self,
                                                                     source: source,
                                                                     destination: destination,
                                                                     waitingBorrows: waitingBorrows,
                                                                     borrowType: borrowType))
    }
    
    private func showFundsMoveEditScreen(source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel, returningBorrow: BorrowViewModel?) {
        modal(factory.transactionEditViewController(delegate: self,
                                                    source: source,
                                                    destination: destination,
                                                    returningBorrow: returningBorrow))
    }
    
    private func showBorrowEditScreen(source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel) {
        let type = source.isDebt ? BorrowType.loan : BorrowType.debt
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination))
    }
    
    private func showExpenseEditScreen(source: TransactionSource, destination: TransactionDestination) {
        modal(factory.transactionEditViewController(delegate: self,
                                                    source: source,
                                                    destination: destination,
                                                    returningBorrow: nil))
    }
}

extension MainViewController : WaitingBorrowsViewControllerDelegate {
    func didSelect(borrow: BorrowViewModel, source: ExpenseSourceViewModel, destination: ExpenseSourceViewModel) {
        showFundsMoveEditScreen(source: source, destination: destination, returningBorrow: borrow)
    }
}
