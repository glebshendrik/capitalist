//
//  ExpenseCategoryEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        loadBudget()
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        loadBudget()
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        loadExpenseCategories(by: basketType)
        loadBaskets()
        loadBudget()
        loadExpenseSources()
    }
}

extension MainViewController {
    func didSelectExpenseCategory(at indexPath: IndexPath, basketType: BasketType) {
        if viewModel.isAddCategoryItem(indexPath: indexPath) {
            showNewExpenseCategoryScreen(basketType: basketType)
        } else if let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) {
            if isSelecting {
                select(expenseCategoryViewModel, collectionView: joyExpenseCategoriesCollectionView, indexPath: indexPath)
            }
            else {
                showExpenseCategoryInfo(expenseCategory: expenseCategoryViewModel)
            }
        }
    }
    
    func expenseCategoryCollectionViewCell(forItemAt indexPath: IndexPath, basketType: BasketType) -> UICollectionViewCell {
        
        let collectionView = basketItemsCollectionView(by: basketType)
        
        if viewModel.isAddCategoryItem(indexPath: indexPath) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddExpenseCategoryCollectionViewCell",
                                                      for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpenseCategoryCollectionViewCell",
                                                            for: indexPath) as? ExpenseCategoryCollectionViewCell,
            let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = expenseCategoryViewModel
        return cell
    }
}


