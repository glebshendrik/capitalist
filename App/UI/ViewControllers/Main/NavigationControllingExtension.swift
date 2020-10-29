//
//  NavigationControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension MainViewController {
    func showStatistics(with filterViewModel: TransactionableFilter?) {
        modal(factory.statisticsModalViewController(filter: filterViewModel))
    }
    
    func showIncomeStatistics() {
        modal(factory.statisticsModalViewController(graphType: .incomes))
    }
}

extension MainViewController {
    func showBalance() {
        modal(factory.balanceViewController())
    }
}

extension MainViewController {
//    func showNewIncomeSourceScreen() {
//        showEditScreen(incomeSource: nil)
//    }
    
//    func showEditScreen(incomeSource: IncomeSource?) {
//        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
//    }
    
//    func showIncomeSourceInfoScreen(incomeSource: IncomeSourceViewModel?) {
//        modal(factory.incomeSourceInfoViewController(incomeSource: incomeSource))
//    }
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
    
    func showExpenseSourceInfoScreen(expenseSourceId: Int?) {
        guard
            let expenseSourceId = expenseSourceId
        else {
            return
        }
        messagePresenterManager.showHUD()
        _ = firstly {
                viewModel.loadExpenseSource(id: expenseSourceId)
            }.ensure {
                self.messagePresenterManager.dismissHUD()
            }.done {
                self.modal(self.factory.expenseSourceInfoViewController(expenseSource: $0))
            }
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
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: creditId,
                                               source: nil,
                                               destination: nil,
                                               creditingTransaction: nil))
    }
}

extension MainViewController {
    func showNewActiveScreen(basketType: BasketType) {
        showActiveEditScreen(active: nil, basketType: basketType)
    }
    
    func showActiveEditScreen(active: Active?, basketType: BasketType) {    
        modal(factory.activeEditViewController(delegate: self, active: active, basketType: basketType, costCents: nil))
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
    
    func showTransactionEditScreen(source: Transactionable? = nil, destination: Transactionable? = nil, transactionType: TransactionType? = nil) {
        modal(factory.transactionEditViewController(delegate: self, source: source, destination: destination, transactionType: transactionType))
    }
       
    private func showReturnTransactionEditScreen(source: Transactionable, destination: Transactionable, returningBorrow: BorrowViewModel?) {
        modal(factory.transactionEditViewController(delegate: self,
                                                    source: source,
                                                    destination: destination,
                                                    returningBorrow: returningBorrow,
                                                    transactionType: nil))
    }
        
    private func showExpenseEditScreen(source: ExpenseSourceViewModel, destination: ExpenseCategoryViewModel) {
        if destination.hasWaitingLoans {
            showBorrowingExpenseSheet(source: source, destination: destination)
        }
        else if destination.isBorrowOrReturn {
            showBorrowEditScreen(type: .debt, source: source, destination: destination, borrowingTransaction: nil)
        }
        else {
            showTransactionEditScreen(source: source, destination: destination)
        }
    }
    
    private func showBorrowingIncomeSheet(source: IncomeSourceViewModel, destination: ExpenseSourceViewModel) {
        let creditAction = UIAlertAction(title: NSLocalizedString("Взять в кредит", comment: "Взять в кредит"), style: .default) { _ in
            self.showCreditEditScreen(source: source, destination: destination, creditingTransaction: nil)
        }
        
        let loanAction = UIAlertAction(title: NSLocalizedString("Занять", comment: "Занять"), style: .default) { _ in
            self.showBorrowEditScreen(type: .loan, source: source, destination: destination, borrowingTransaction: nil)
        }
        
        let returnAction = UIAlertAction(title: NSLocalizedString("Возвращение долга", comment: "Возвращение долга"), style: .default) { _ in
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
        
        let debtAction = UIAlertAction(title: NSLocalizedString("Одолжить", comment: "Одолжить"), style: .default) { _ in
            self.showBorrowEditScreen(type: .debt, source: source, destination: destination, borrowingTransaction: nil)
        }
        
        let returnAction = UIAlertAction(title: NSLocalizedString("Возвращение займа", comment: "Возвращение займа"), style: .default) { _ in
            self.showWaitingBorrows(destination.waitingLoans,
                                    source: source,
                                    destination: destination,
                                    borrowType: .loan)
        }
        
        sheet(title: nil, actions: [debtAction, returnAction])
    }
    
    func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination, borrowingTransaction: Transaction?) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination,
                                               borrowingTransaction: borrowingTransaction))
    }
    
    func showCreditEditScreen(source: IncomeSourceViewModel?,
                              destination: TransactionDestination,
                              creditingTransaction: Transaction?) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               source: source,
                                               destination: destination,
                                               creditingTransaction: creditingTransaction))
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

extension MainViewController : Navigatable, Updatable {
    func update() {
        loadData()
    }
    
    var viewController: Infrastructure.ViewController {
        return Infrastructure.ViewController.MainViewController
    }
    
    var presentingCategories: [NotificationCategory] {
        return []
    }
    
    func navigate(to viewController: Infrastructure.ViewController, with category: NotificationCategory) {
        switch category {
            case .saltedgeNotification(let expenseSourceId):
                guard
                    viewController == .ExpenseSourceInfoViewController
                else {
                    return
                }
                showExpenseSourceInfoScreen(expenseSourceId: expenseSourceId)
            default:
                return
        }
    }
}
