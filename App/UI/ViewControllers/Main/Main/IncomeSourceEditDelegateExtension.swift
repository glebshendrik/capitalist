//
//  IncomeSourceEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource() {
        loadIncomeSources()
    }
    
    func didUpdateIncomeSource() {
        loadIncomeSources()        
    }
    
    func didRemoveIncomeSource() {
        loadIncomeSources()
        loadBudget()
        loadExpenseSources()
    }
}

extension MainViewController {
    
    func didSelectIncomeSource(at indexPath: IndexPath) {
        if viewModel.isAddIncomeSourceItem(indexPath: indexPath) {
            showNewIncomeSourceScreen()
        } else if let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) {
            if isSelecting {
                select(incomeSourceViewModel, collectionView: incomeSourcesCollectionView, indexPath: indexPath)
            }
            else {
                showIncomeSourceInfoScreen(incomeSource: incomeSourceViewModel)
            }            
        }
    }
    
    func incomeSourceCollectionViewCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if viewModel.isAddIncomeSourceItem(indexPath: indexPath) {
            return incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "AddIncomeSourceCollectionViewCell",
                                                                   for: indexPath)
        }
        
        guard let cell = incomeSourcesCollectionView.dequeueReusableCell(withReuseIdentifier: "IncomeSourceCollectionViewCell",
                                                                         for: indexPath) as? IncomeSourceCollectionViewCell,
            let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = incomeSourceViewModel
        return cell
    }
    
    func scrollIncomeSourcesToBeginning() {
        incomeSourcesCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
}
