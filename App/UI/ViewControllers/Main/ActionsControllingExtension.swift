//
//  ActionsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import EasyTipView

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
        view.haptic()
    }
    
    func setSelecting(_ selecting: Bool, animated: Bool) {
        guard selecting != isSelecting else { return }
        
        viewModel.set(selecting: selecting)
        updateMainButtonUI()
        updateTotalUI(animated: true)
        if isSelecting {
            updateAdviserTip()
        }
        else {
            completeTransactionInteraction()            
        }
        updateCollectionViews()
        view.haptic()
    }
    
    func updateMainButtonUI() {
        let isCancelState = isEditingItems || isSelecting
        
        let transform = isCancelState ? CGAffineTransform(rotationAngle: CGFloat(3 * Double.pi / 4)) : .identity
        let color = isCancelState ? UIColor.by(ColorAsset.red1) : UIColor.by(.blue1)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.mainButton.transform = transform
                self.mainButton.backgroundColor = color
            })
    }
}

extension MainViewController : EasyTipViewDelegate {
    private func showTransactionCreationInfoViewController() {
        slideUp(factory.transactionCreationInfoViewController(),
                toBottomOf: incomeSourcesContainer,
                shouldDim: true)
    }
    
    func show(tipMessage: String) {
        adviserTip = tip(text: tipMessage, position: .left)
        adviserTip?.show(animated: true, forView: titleView.tipAnchor, withinSuperview: titleView)
    }
    
    func updateAdviserTip() {
        func showAdviserTip() {
            guard let tipMessage = self.viewModel.adviserTip else { return }            
            show(tipMessage: tipMessage)
        }
        
        guard let tip = adviserTip else {
            showAdviserTip()
            return
        }
        tip.dismiss(withCompletion: {
            showAdviserTip()
        })
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
    }
    
    func tip(text: String, position: EasyTipView.ArrowPosition) -> EasyTipView {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Roboto-Light", size: 14)!
        preferences.drawing.foregroundColor = UIColor.by(.white100)
        preferences.drawing.backgroundColor = UIColor.by(.blue1)
        preferences.drawing.arrowPosition = position
        preferences.drawing.cornerRadius = 8
        preferences.positioning.contentVInset = 2
        preferences.animating.showDuration = 0.3
        preferences.animating.dismissDuration = 0.2
        
        return EasyTipView(text: text, preferences: preferences, delegate: self)
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

extension MainViewController {
    @objc func appMovedToForeground() {
        setVisibleCells(editing: isEditingItems)        
    }
}

extension MainViewController {
    @objc func finantialDataInvalidated() {
        loadData()
    }
}
