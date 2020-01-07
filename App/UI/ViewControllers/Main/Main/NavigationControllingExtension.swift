//
//  NavigationControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func showStatistics(with filterViewModel: TransactionableFilter?) {
        modal(factory.statisticsModalViewController(filter: filterViewModel))
    }
}

extension MainViewController {
    func showBalance() {
        modal(factory.balanceViewController())
    }
}

extension MainViewController {
    func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
    }
    
    func showIncomeSourceInfoScreen(incomeSource: IncomeSourceViewModel?) {
        modal(factory.incomeSourceInfoViewController(incomeSource: incomeSource))
    }
}

extension MainViewController {
    func showNewExpenseSourceScreen() {
        showEditScreen(expenseSource: nil)
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource))
    }
    
    func showExpenseSourceInfoScreen(expenseSource: ExpenseSourceViewModel?) {
        modal(factory.expenseSourceInfoViewController(expenseSource: expenseSource))
    }
}

extension MainViewController {
    func showNewExpenseCategoryScreen(basketType: BasketType) {
        showEditScreen(expenseCategory: nil, basketType: basketType)
    }
    
    func showExpenseCategoryInfo(expenseCategory: ExpenseCategoryViewModel) {
        if let creditId = expenseCategory.creditId {
            modal(factory.creditInfoViewController(creditId: creditId, credit: nil))            
        } else {
            modal(factory.expenseCategoryInfoViewController(expenseCategory: expenseCategory))
        }
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
        modal(factory.creditEditViewController(delegate: self, creditId: creditId, destination: nil))
    }
}

extension MainViewController {
    func showNewActiveScreen(basketType: BasketType) {
        showActiveEditScreen(active: nil, basketType: basketType)
    }
    
    func showActiveEditScreen(active: Active?, basketType: BasketType) {    
        modal(factory.activeEditViewController(delegate: self, active: active, basketType: basketType))
    }
    
    func showActiveInfo(active: ActiveViewModel) {
        modal(factory.activeInfoViewController(active: active))
    }
}

extension MainViewController {
    func showTransactionEditScreen(transactionSource: TransactionSource, transactionDestination: TransactionDestination) {
        soundsManager.playTransactionStartedSound()
        switch (transactionSource, transactionDestination) {
        case (let source as IncomeSourceViewModel, let destination as ExpenseSourceViewModel):
            showIncomeEditScreen(source: source, destination: destination)
        case (let source as IncomeSourceViewModel, let destination as ActiveViewModel):
            showTransactionEditScreen(source: source, destination: destination)
        case (let source as ActiveViewModel, let destination as ExpenseSourceViewModel):
            showTransactionEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseSourceViewModel):
            showTransactionEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ExpenseCategoryViewModel):
            showExpenseEditScreen(source: source, destination: destination)
        case (let source as ExpenseSourceViewModel, let destination as ActiveViewModel):
            showTransactionEditScreen(source: source, destination: destination)
        default:
            return
        }
    }
    
    private func showIncomeEditScreen(source: IncomeSourceViewModel, destination: ExpenseSourceViewModel) {
        if source.isBorrowOrReturn {
            showBorrowingIncomeSheet(source: source, destination: destination)
        }
        else {
            showTransactionEditScreen(source: source, destination: destination)
        }
    }
    
    private func showTransactionEditScreen(source: Transactionable?, destination: Transactionable?) {
        modal(factory.transactionEditViewController(delegate: self, source: source, destination: destination))
    }
       
    private func showReturnTransactionEditScreen(source: Transactionable, destination: Transactionable, returningBorrow: BorrowViewModel?) {
        modal(factory.transactionEditViewController(delegate: self,
                                                    source: source,
                                                    destination: destination,
                                                    returningBorrow: returningBorrow))
    }
        
    private func showExpenseEditScreen(source: ExpenseSourceViewModel, destination: ExpenseCategoryViewModel) {
        if destination.hasWaitingLoans {
            showBorrowingExpenseSheet(source: source, destination: destination)
        }
        else if destination.isBorrowOrReturn {
            showBorrowEditScreen(type: .debt, source: source, destination: destination)
        }
        else {
            showTransactionEditScreen(source: source, destination: destination)
        }
    }
    
    private func showBorrowingIncomeSheet(source: IncomeSourceViewModel, destination: ExpenseSourceViewModel) {
        let creditAction = UIAlertAction(title: "Взять в кредит", style: .default) { _ in
            self.showCreditEditScreen(destination: destination)
        }
        
        let loanAction = UIAlertAction(title: "Занять", style: .default) { _ in
            self.showBorrowEditScreen(type: .loan, source: source, destination: destination)
        }
        
        let returnAction = UIAlertAction(title: "Возвращение долга", style: .default) { _ in
            self.showWaitingBorrows(source.waitingDebts,
                                    source: source,
                                    destination: destination,
                                    borrowType: .debt)
        }
        
        var actions: [UIAlertAction] = [creditAction, loanAction]
        
        if source.hasWaitingDebts {
            actions.append(returnAction)
        }
        
        sheet(title: nil, actions: actions)
    }
    
    private func showBorrowingExpenseSheet(source: ExpenseSourceViewModel, destination: ExpenseCategoryViewModel) {
        guard destination.hasWaitingLoans else { return }
        
        let debtAction = UIAlertAction(title: "Одолжить", style: .default) { _ in
            self.showBorrowEditScreen(type: .debt, source: source, destination: destination)
        }
        
        let returnAction = UIAlertAction(title: "Возвращение займа", style: .default) { _ in
            self.showWaitingBorrows(destination.waitingLoans,
                                    source: source,
                                    destination: destination,
                                    borrowType: .loan)
        }
        
        sheet(title: nil, actions: [debtAction, returnAction])
    }
    
    private func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination))
    }
    
    private func showCreditEditScreen(destination: TransactionDestination) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               destination: destination))
    }
    
    private func showWaitingBorrows(_ waitingBorrows: [BorrowViewModel], source: TransactionSource, destination: TransactionDestination, borrowType: BorrowType) {
                
        slideUp(factory.waitingBorrowsViewController(delegate: self,
                                                     source: source,
                                                     destination: destination,
                                                     waitingBorrows: waitingBorrows,
                                                     borrowType: borrowType))
    }
}

extension MainViewController : WaitingBorrowsViewControllerDelegate {
    func didSelect(borrow: BorrowViewModel, source: TransactionSource, destination: TransactionDestination) {
        showReturnTransactionEditScreen(source: source, destination: destination, returningBorrow: borrow)
    }
}
