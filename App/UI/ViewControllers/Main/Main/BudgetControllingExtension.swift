//
//  BudgetControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AttributedTextView

extension MainViewController : TitleViewDelegate {
    var total: NSAttributedString {
        return (self.viewModel.basketTotalTitle.color(UIColor.by(.text9EAACC))
                + self.viewModel.basketTotal.color(UIColor.by(.textFFFFFF)))
                .all.fontName("Rubik-Regular").size(13).attributedText
    }
    
    func didTapTitle() {
        showBalance()
    }
    
    func updateBudgetUI() {
        
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.incomeSourcesAmountLabel.text = self.viewModel.incomesAmountRounded
            self.expenseSourcesAmountLabel.text = self.viewModel.expenseSourcesAmountRounded
            self.basketTotalLabel.attributedText = self.total
        })
    }
    
    func updateTotalUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                                        
            self.basketTotalLabel.attributedText = self.total
            self.basketTotalLabel.alpha = self.isEditing ? 0.0 : 1.0
        })
    }
}
