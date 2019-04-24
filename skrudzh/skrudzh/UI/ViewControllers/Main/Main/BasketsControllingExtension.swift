//
//  BasketsControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension MainViewController {
    func didTapBasket(with basketType: BasketType) {
        viewModel.basketsViewModel.selectBasketBy(basketType: basketType)
        updateBasketsUI()
    }
    
    func updateBasketsUI() {
        updateBasketsRatiosUI()
        updateBasketsTabsUI()
        updateBasketExpenseCategoriesContainer()
    }
    
    private func updateBasketsRatiosUI() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyBasketProgressConstraint = self.joyBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.joyBasketRatio)
            
            self.riskBasketProgressConstraint = self.riskBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.riskBasketRatio)
            
            self.safeBasketProgressConstraint = self.safeBasketProgressConstraint.setMultiplier(multiplier: self.viewModel.basketsViewModel.safeBasketRatio)
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    private func updateBasketsTabsUI() {
        let selectedTextColor = UIColor(red: 0.25, green: 0.27, blue: 0.38, alpha: 1)
        let unselectedTextColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.joyBasketSpentLabel.text = self.viewModel.basketsViewModel.joyBasketSpent
                            self.joyBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isJoyBasketSelected ? selectedTextColor : unselectedTextColor
                            self.joyBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isJoyBasketSelected
                            
                            self.riskBasketSpentLabel.text = self.viewModel.basketsViewModel.riskBasketSpent
                            self.riskBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isRiskBasketSelected ? selectedTextColor : unselectedTextColor
                            self.riskBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isRiskBasketSelected
                            
                            self.safeBasketSpentLabel.text = self.viewModel.basketsViewModel.safeBasketSpent
                            self.safeBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isSafeBasketSelected ? selectedTextColor : unselectedTextColor
                            self.safeBasketSelectionIndicator.isHidden = !self.viewModel.basketsViewModel.isSafeBasketSelected
        })
    }
    
    private func updateBasketExpenseCategoriesContainer() {
        let lowPriority = UILayoutPriority(integerLiteral: 998)
        let highPriority = UILayoutPriority(integerLiteral: 999)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isJoyBasketSelected ? highPriority : lowPriority
            self.riskExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isRiskBasketSelected ? highPriority : lowPriority
            self.safeExpenseCategoriesLeftConstraint.priority = self.viewModel.basketsViewModel.isSafeBasketSelected ? highPriority : lowPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
}
