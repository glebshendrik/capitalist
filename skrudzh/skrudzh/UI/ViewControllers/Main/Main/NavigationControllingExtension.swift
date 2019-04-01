//
//  NavigationControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
    func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        if  let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController,
            let incomeSourceEditViewController = incomeSourceEditNavigationController.topViewController as? IncomeSourceEditInputProtocol {
            
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
            let expenseSourceEditViewController = expenseSourceEditNavigationController.topViewController as? ExpenseSourceEditInputProtocol {
            
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
        if  let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController,
            let expenseCategoryEditViewController = expenseCategoryEditNavigationController.topViewController as? ExpenseCategoryEditInputProtocol {
            
            expenseCategoryEditViewController.set(delegate: self)
            expenseCategoryEditViewController.set(basketType: basketType)
            
            if let expenseCategory = expenseCategory {
                expenseCategoryEditViewController.set(expenseCategory: expenseCategory)
            }
            
            present(expenseCategoryEditNavigationController, animated: true, completion: nil)
        }
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
            let incomeEditViewController = incomeEditNavigationController.topViewController as? IncomeEditInputProtocol {
            
            incomeEditViewController.set(delegate: self)
            
            incomeEditViewController.set(startable: incomeSourceStartable, completable: expenseSourceCompletable)
            
            present(incomeEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showFundsMoveEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseSourceCompletable: ExpenseSourceViewModel) {
        if  let fundsMoveEditNavigationController = router.viewController(.FundsMoveEditNavigationController) as? UINavigationController,
            let fundsMoveEditViewController = fundsMoveEditNavigationController.topViewController as? FundsMoveEditInputProtocol {
            
            fundsMoveEditViewController.set(delegate: self)
            
            fundsMoveEditViewController.set(startable: expenseSourceStartable, completable: expenseSourceCompletable)
            
            present(fundsMoveEditNavigationController, animated: true, completion: nil)
        }
    }
    
    private func showExpenseEditScreen(expenseSourceStartable: ExpenseSourceViewModel, expenseCategoryCompletable: ExpenseCategoryViewModel) {
        if  let expenseEditNavigationController = router.viewController(.ExpenseEditNavigationController) as? UINavigationController,
            let expenseEditViewController = expenseEditNavigationController.topViewController as? ExpenseEditInputProtocol {
            
            expenseEditViewController.set(delegate: self)
            
            expenseEditViewController.set(startable: expenseSourceStartable, completable: expenseCategoryCompletable)
            
            present(expenseEditNavigationController, animated: true, completion: nil)
        }
    }
}
