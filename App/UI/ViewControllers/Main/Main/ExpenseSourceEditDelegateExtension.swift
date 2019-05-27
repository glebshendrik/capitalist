//
//  ExpenseSourceEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadExpenseSources()
        loadBudget()
    }
    
    func didUpdateExpenseSource() {
        loadExpenseSources()
        loadBudget()
    }
    
    func didRemoveExpenseSource() {
        loadExpenseSources()
        loadBudget()
        loadBaskets()
        loadIncomeSources()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .safe)
        loadExpenseCategories(by: .risk)
    }
}

extension MainViewController {
    
    func didSelectExpenseSource(at indexPath: IndexPath) {
        if viewModel.isAddExpenseSourceItem(indexPath: indexPath) {
            showNewExpenseSourceScreen()
        } else if let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) {
            
            let filterViewModel = ExpenseSourceHistoryTransactionFilter(expenseSourceViewModel: expenseSourceViewModel)
            showStatistics(with: filterViewModel)
        }
    }
    
    func expenseSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.isAddExpenseSourceItem(indexPath: indexPath) {
            return expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "AddExpenseSourceCollectionViewCell",
                                                                    for: indexPath)
        }
        
        guard let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath)
            else {
                
                return UICollectionViewCell()
        }
        
        if expenseSourceViewModel.isGoal,
            let cell = expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "GoalExpenseSourceCollectionViewCell",
                                                                        for: indexPath) as? GoalExpenseSourceCollectionViewCell {
            
            cell.viewModel = expenseSourceViewModel
            return cell
        }
        
        if !expenseSourceViewModel.isGoal,
            let cell = expenseSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseSourceCollectionViewCell",
                                                                        for: indexPath) as? ExpenseSourceCollectionViewCell {
            
            cell.viewModel = expenseSourceViewModel
            return cell
        }
        
        return UICollectionViewCell()
    }
}
