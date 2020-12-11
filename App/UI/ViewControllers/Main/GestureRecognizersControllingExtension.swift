//
//  GestureRecognizersControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let longPressureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer else { return true }
        return !longPressureRecognizers.contains(longPressureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view is UIButton {
            return false
        }
        
        let locationInView = touch.location(in: self.view)
            
        let collectionViews: [UICollectionView] = [expenseSourcesCollectionView,
                                                   joyExpenseCategoriesCollectionView,
                                                   riskActivesCollectionView,
                                                   safeActivesCollectionView]
        
        let intersections = detectCollectionViewIntersection(at: locationInView,
                                                             in: self.view,
                                                             collectionViewsPool: collectionViews)
        
        guard   let collectionView = intersections?.collectionView,
            let indexPath = intersections?.indexPath else {
                return true
        }
        
        switch collectionView {        
        case expenseSourcesCollectionView:
            return !viewModel.isAddExpenseSourceItem(indexPath: indexPath)
        case joyExpenseCategoriesCollectionView:
            return !viewModel.isAddCategoryItem(indexPath: indexPath)
        case riskActivesCollectionView:
            return !viewModel.isAddActiveItem(indexPath: indexPath, basketType: .risk)
        case safeActivesCollectionView:
            return !viewModel.isAddActiveItem(indexPath: indexPath, basketType: .safe)
        default:
            return true
        }
    }
    
    func updateLongPressureRecognizers() {
        longPressureRecognizers.forEach {
            $0.minimumPressDuration = isEditingItems
                ? fastPressDuration
                : slowPressDuration
        }
        transactionRecognizer?.minimumPressDuration = fastPressDuration
    }
}
