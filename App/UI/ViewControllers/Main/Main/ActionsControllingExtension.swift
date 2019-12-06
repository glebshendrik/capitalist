//
//  ActionsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func tapMainButton() {
        if isEditingItems {
            setEditingItems(false, animated: true)
        }
        else {
            setSelecting(!isSelecting, animated: true)
        }
    }
    
    func setEditingItems(_ editing: Bool, animated: Bool) {
        guard editing != isEditingItems else { return }
                
        viewModel.set(editing: editing)
        setVisibleCells(editing: editing)
        updateCollectionViews()
        updateLongPressureRecognizers()
        updateTotalUI(animated: true)        
        updateMainButtonUI()
    }
    
    func setSelecting(_ selecting: Bool, animated: Bool) {
        guard selecting != isSelecting else { return }
        
        viewModel.set(selecting: selecting)
        updateMainButtonUI()
        updateTotalUI(animated: true)
        if !isSelecting {
            completeTransactionInteraction()
        }
        else if isSelecting && !UIFlowManager.reached(point: .transactionCreationInfoMessage) {
            showTransactionCreationInfoViewController()
        }
        updateCollectionViews()
    }
    
    func updateMainButtonUI() {
        let isCancelState = isEditingItems || isSelecting
        
        let transform = isCancelState ? CGAffineTransform(rotationAngle: CGFloat(3 * Double.pi / 4)) : .identity
        let color = isCancelState ? UIColor.by(ColorAsset.redE5487C) : UIColor.by(.blue6A92FA)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.mainButton.transform = transform
                self.mainButton.backgroundColor = color
            })
    }
}

extension MainViewController {
    private func showTransactionCreationInfoViewController() {
        slideUp(factory.transactionCreationInfoViewController(),
                toBottomOf: incomeSourcesContainer,
                shouldDim: true)
    }
}

extension MainViewController {
    func setVisibleCells(editing: Bool) {
        let cells = incomeSourcesCollectionView.visibleCells + expenseSourcesCollectionView.visibleCells + joyExpenseCategoriesCollectionView.visibleCells + riskActivesCollectionView.visibleCells + safeActivesCollectionView.visibleCells
        
        for cell in cells {
            cell.set(editing: editing)
        }
    }
}
