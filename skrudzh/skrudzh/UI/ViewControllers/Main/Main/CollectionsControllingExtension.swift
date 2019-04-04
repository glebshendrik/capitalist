//
//  CollectionsControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:           return 1
        case expenseSourcesCollectionView:          return 1
        case joyExpenseCategoriesCollectionView:    return 1
        case riskExpenseCategoriesCollectionView:   return 1
        case safeExpenseCategoriesCollectionView:   return 1
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case incomeSourcesCollectionView:           return viewModel.numberOfIncomeSources
        case expenseSourcesCollectionView:          return viewModel.numberOfExpenseSources
        case joyExpenseCategoriesCollectionView:    return viewModel.numberOfJoyExpenseCategories
        case riskExpenseCategoriesCollectionView:   return viewModel.numberOfRiskExpenseCategories
        case safeExpenseCategoriesCollectionView:   return viewModel.numberOfSafeExpenseCategories
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        func collectionViewCell() -> UICollectionViewCell {
            switch collectionView {
            case incomeSourcesCollectionView:           return incomeSourceCollectionViewCell(forItemAt: indexPath)
            case expenseSourcesCollectionView:          return expenseSourceCollectionViewCell(forItemAt: indexPath)
            case joyExpenseCategoriesCollectionView:    return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .joy)
            case riskExpenseCategoriesCollectionView:   return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .risk)
            case safeExpenseCategoriesCollectionView:   return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .safe)
            default:                                    return UICollectionViewCell()
            }
        }
        
        let cell = collectionViewCell()
        
        guard let editableCell = cell as? EditableCell else { return cell }
        
        if isEditing {
            if indexPath != rearrangeController.movingIndexPath || collectionView != rearrangeController.movingCollectionView {
                editableCell.set(editing: true)
            }
        } else {
            editableCell.set(editing: false)
        }
        
        editableCell.delegate = self
        
        if collectionView == rearrangeController.movingCollectionView {
            if indexPath == rearrangeController.movingIndexPath {
                cell.alpha = 0.99
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                cell.alpha = 1.0
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == transactionController.transactionStartedCollectionView {
            if indexPath == transactionController.transactionStartedIndexPath {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == transactionController.dropCandidateCollectionView {
            if indexPath == transactionController.dropCandidateIndexPath {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
        if collectionView == transactionController.transactionStartedCollectionView && collectionView == transactionController.dropCandidateCollectionView {
            if indexPath == transactionController.transactionStartedIndexPath {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            else if indexPath == transactionController.dropCandidateIndexPath {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        switch collectionView {
        case incomeSourcesCollectionView:           moveIncomeSource(from: sourceIndexPath,
                                                                     to: destinationIndexPath)
        case expenseSourcesCollectionView:          moveExpenseSource(from: sourceIndexPath,
                                                                      to: destinationIndexPath)
        case joyExpenseCategoriesCollectionView:    moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .joy)
        case riskExpenseCategoriesCollectionView:   moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .risk)
        case safeExpenseCategoriesCollectionView:   moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .safe)
        default: return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditing else { return }
        
        switch collectionView {
        case incomeSourcesCollectionView:           didSelectIncomeSource(at: indexPath)
        case expenseSourcesCollectionView:          didSelectExpenseSource(at: indexPath)
        case joyExpenseCategoriesCollectionView:    didSelectExpenseCategory(at: indexPath, basketType: .joy)
        case riskExpenseCategoriesCollectionView:   didSelectExpenseCategory(at: indexPath, basketType: .risk)
        case safeExpenseCategoriesCollectionView:   didSelectExpenseCategory(at: indexPath, basketType: .safe)
        default: return
        }
    }
}

extension MainViewController {
    func updateCollectionViews() {
        update(incomeSourcesCollectionView)
        update(expenseSourcesCollectionView)
        update(joyExpenseCategoriesCollectionView)
        update(riskExpenseCategoriesCollectionView)
        update(safeExpenseCategoriesCollectionView)
    }
}

extension MainViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl(for: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePageControl(for: scrollView)
    }
    
    func switchOffScrolling(for collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.panGestureRecognizer.isEnabled = false
        collectionView.panGestureRecognizer.isEnabled = true
    }
}