//
//  BasketsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func didTapBasket(with basketType: BasketType) {
        scrollBasketAtTopIfNeeded(basketType: basketType)
        viewModel.basketsViewModel.selectBasketType(basketType)
        updateBasketsUI()
    }
    
    func updateBasketsUI() {
        updateBasketsRatiosUI(animated: true)
        updateBasketsTabsUI(animated: true)
        showBasketContent()
        updateTotalUI(animated: true)
    }
    
    func scrollBasketAtTopIfNeeded(basketType: BasketType) {
        guard basketType == viewModel.basketsViewModel.selectedBasketType else { return }
        let collectionView = basketItemsCollectionView(by: basketType)
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func scrollIncomeSourcesToBeginning() {
        incomeSourcesCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func scrollExpenseSourcesToBeginning() {
        expenseSourcesCollectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func showBasketContent() {
        basketsContentScrollView.setContentOffset(basketContentOffset(by: viewModel.basketsViewModel.selectedBasketType), animated: true)
    }
    
    func updateBasketTransition() {
        let joyRatio = basketContentRatio(basketType: .joy)
        let safeRatio = basketContentRatio(basketType: .safe)
        let riskRatio = basketContentRatio(basketType: .risk)
        let basketType = viewModel.basketsViewModel.selectedBasketType
        viewModel.basketsViewModel.updateRatios(joyRatio: joyRatio, safeRatio: safeRatio, riskRatio: riskRatio)
        updateBasketsRatiosUI(animated: false)
        updateBasketsTabsUI(animated: false)
        if basketType != viewModel.basketsViewModel.selectedBasketType {
            updateTotalUI(animated: false)
        }        
    }
    
    func basketContentRatio(basketType: BasketType) -> CGFloat {
        let width = basketsContentScrollView.frame.width
        let offset = basketsContentScrollView.contentOffset.x
        let basketOffset = basketContentOffset(by: basketType).x
        let distance = (offset - basketOffset).abs
        let diff = width - distance
        if diff < 0 {
            return 0
        }
        return diff / width
    }
    
    func basketContentOffset(by basketType: BasketType) -> CGPoint {
        switch basketType {
        case .joy:
            return CGPoint.zero
        case .safe:
            return CGPoint(x: basketsContentScrollView.frame.width * 1, y: 0)
        case .risk:
            return CGPoint(x: basketsContentScrollView.frame.width * 2, y: 0)
        }
    }
    
    private func updateBasketsRatiosUI(animated: Bool) {
        func update() {
            joyBasketProgressConstraint = joyBasketProgressConstraint.setMultiplier(multiplier: viewModel.basketsViewModel.joyBasketRatio)
            
            riskBasketProgressConstraint = riskBasketProgressConstraint.setMultiplier(multiplier: viewModel.basketsViewModel.riskBasketRatio)
            
            safeBasketProgressConstraint = safeBasketProgressConstraint.setMultiplier(multiplier: viewModel.basketsViewModel.safeBasketRatio)
            
            view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                
                update()
            }, completion: nil)
        }
        else {
            update()
        }
    }
    
    private func updateBasketsTabsUI(animated: Bool) {
        let selectedTextColor = UIColor.by(.textFFFFFF)
        let unselectedTextColor = UIColor.by(.text9EAACC)
        
        let joyColor = unselectedTextColor.toColor(selectedTextColor, ratio: viewModel.basketsViewModel.joyRatio)
        let safeColor = unselectedTextColor.toColor(selectedTextColor, ratio: viewModel.basketsViewModel.safeRatio)
        let riskColor = unselectedTextColor.toColor(selectedTextColor, ratio: viewModel.basketsViewModel.riskRatio)
                
        func update() {
            joyBasketSpentLabel.text = viewModel.basketsViewModel.joyBasketSpent
            joyBasketTitleLabel.textColor = joyColor
            joyBasketSpentLabel.textColor = joyColor
            
            safeBasketSpentLabel.text = viewModel.basketsViewModel.safeBasketSpent
            safeBasketTitleLabel.textColor = safeColor
            safeBasketSpentLabel.textColor = safeColor
            
            riskBasketSpentLabel.text = viewModel.basketsViewModel.riskBasketSpent
            riskBasketTitleLabel.textColor = riskColor
            riskBasketSpentLabel.textColor = riskColor
        }
        if animated {
            UIView.transition(with: view,
                              duration: 0.1,
                              options: .transitionCrossDissolve,
                              animations: {
                                
                                update()                                
            })
        }
        else {
            update()
        }
    }
}
