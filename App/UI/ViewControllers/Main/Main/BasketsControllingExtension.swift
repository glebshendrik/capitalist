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
        let selectedTextColor = UIColor.by(.textFFFFFF)
        let unselectedTextColor = UIColor.by(.text9EAACC)
        let selectedAmountFont = UIFont(name: "Rubik-Medium", size: 15)
        let unselectedAmountFont = UIFont(name: "Rubik-Regular", size: 15)
        
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.joyBasketSpentLabel.text = self.viewModel.basketsViewModel.joyBasketSpent
                            self.joyBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isJoyBasketSelected ? selectedTextColor : unselectedTextColor
                            self.joyBasketSpentLabel.textColor = self.viewModel.basketsViewModel.isJoyBasketSelected ? selectedTextColor : unselectedTextColor
                            self.joyBasketSpentLabel.font = self.viewModel.basketsViewModel.isJoyBasketSelected ? selectedAmountFont : unselectedAmountFont
                            
                            

                            
                            self.riskBasketSpentLabel.text = self.viewModel.basketsViewModel.riskBasketSpent
                            self.riskBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isRiskBasketSelected ? selectedTextColor : unselectedTextColor
                            self.riskBasketSpentLabel.textColor = self.viewModel.basketsViewModel.isRiskBasketSelected ? selectedTextColor : unselectedTextColor
                            self.riskBasketSpentLabel.font = self.viewModel.basketsViewModel.isRiskBasketSelected ? selectedAmountFont : unselectedAmountFont
                            
                            self.safeBasketSpentLabel.text = self.viewModel.basketsViewModel.safeBasketSpent
                            self.safeBasketTitleLabel.textColor = self.viewModel.basketsViewModel.isSafeBasketSelected ? selectedTextColor : unselectedTextColor
                            self.safeBasketSpentLabel.textColor = self.viewModel.basketsViewModel.isSafeBasketSelected ? selectedTextColor : unselectedTextColor
                            self.safeBasketSpentLabel.font = self.viewModel.basketsViewModel.isSafeBasketSelected ? selectedAmountFont : unselectedAmountFont
        })
    }
    
    private func updateBasketExpenseCategoriesContainer() {
        let lowPriority = UILayoutPriority(integerLiteral: 998)
        let highPriority = UILayoutPriority(integerLiteral: 999)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isJoyBasketSelected ? highPriority : lowPriority
            self.riskActivesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isRiskBasketSelected ? highPriority : lowPriority
            self.safeActivesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isSafeBasketSelected ? highPriority : lowPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
}
