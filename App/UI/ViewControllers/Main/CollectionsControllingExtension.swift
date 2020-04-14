//
//  CollectionsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case expenseSourcesCollectionView:          return 1
        case joyExpenseCategoriesCollectionView:    return 1
        case riskActivesCollectionView:             return 1
        case safeActivesCollectionView:             return 1
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case expenseSourcesCollectionView:          return viewModel.numberOfExpenseSources
        case joyExpenseCategoriesCollectionView:    return viewModel.numberOfJoyExpenseCategories
        case riskActivesCollectionView:             return viewModel.numberOfRiskActives
        case safeActivesCollectionView:             return viewModel.numberOfSafeActives
        default:                                    return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        func collectionViewCell() -> UICollectionViewCell {
            switch collectionView {
            case expenseSourcesCollectionView:          return expenseSourceCollectionViewCell(forItemAt: indexPath)
            case joyExpenseCategoriesCollectionView:    return expenseCategoryCollectionViewCell(forItemAt: indexPath,
                                                                                                 basketType: .joy)
            case riskActivesCollectionView:             return activeCollectionViewCell(forItemAt: indexPath,
                                                                                        basketType: .risk)
            case safeActivesCollectionView:             return activeCollectionViewCell(forItemAt: indexPath,
                                                                                        basketType: .safe)
            default:                                    return UICollectionViewCell()
            }
        }
        
        let cell = collectionViewCell()
        
        guard var editableCell = cell as? TransactionableCellProtocol else { return cell }
                
        editableCell.delegate = self
        
        let isCellEditing = isEditingItems && !rearrangeController.isMoving(collectionView, indexPath: indexPath)
        cell.set(editing: isCellEditing)
        
        
        
        
        transactionController.syncStateOf(collectionView,
                                          cell: cell,
                                          at: indexPath,
                                          animated: false)
        
        rearrangeController.syncStateOf(collectionView,
                                        cell: cell,
                                        at: indexPath,
                                        editing: isCellEditing,
                                        animated: false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        switch collectionView {
        case expenseSourcesCollectionView:          moveExpenseSource(from: sourceIndexPath,
                                                                      to: destinationIndexPath)
        case joyExpenseCategoriesCollectionView:    moveExpenseCategory(from: sourceIndexPath,
                                                                        to: destinationIndexPath,
                                                                        basketType: .joy)
        case riskActivesCollectionView:             moveActive(from: sourceIndexPath,
                                                               to: destinationIndexPath,
                                                               basketType: .risk)
        case safeActivesCollectionView:             moveActive(from: sourceIndexPath,
                                                               to: destinationIndexPath,
                                                               basketType: .safe)
        default: return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditingItems else { return }
        
        switch collectionView {
        case expenseSourcesCollectionView:          didSelectExpenseSource(at: indexPath)
        case joyExpenseCategoriesCollectionView:    didSelectExpenseCategory(at: indexPath, basketType: .joy)
        case riskActivesCollectionView:             didSelectActive(at: indexPath, basketType: .risk)
        case safeActivesCollectionView:             didSelectActive(at: indexPath, basketType: .safe)
        default: return
        }
    }
}

extension MainViewController {
    func updateCollectionViews(animated: Bool = true) {
        update(expenseSourcesCollectionView, animated: animated)
        update(joyExpenseCategoriesCollectionView, animated: animated)
        update(riskActivesCollectionView, animated: animated)
        update(safeActivesCollectionView, animated: animated)
    }
}

extension MainViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == basketsContentScrollView else { return }
        updateBasketTransition()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    func switchOffScrolling(for collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.panGestureRecognizer.isEnabled = false
        collectionView.panGestureRecognizer.isEnabled = true
        basketsContentScrollView.panGestureRecognizer.isEnabled = false
        basketsContentScrollView.panGestureRecognizer.isEnabled = true
    }
    
    func scrollDirection(of collectionView: UICollectionView?) -> UICollectionView.ScrollDirection? {
        guard let collectionView = collectionView else { return nil }
        
        switch collectionView {        
        case expenseSourcesCollectionView:
            return .horizontal
        case joyExpenseCategoriesCollectionView,
             safeActivesCollectionView,
             riskActivesCollectionView:
            return .vertical
        default:
            return .horizontal
        }
    }
}
