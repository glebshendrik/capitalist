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
        if isSelecting {
            return (NSLocalizedString("Из ", comment: "Из ").color(UIColor.by(.white40))
                    + viewModel.selectedSourceName.color(UIColor.by(.white100))
                    + NSLocalizedString(" в ", comment: " в ").color(UIColor.by(.white40))
                    + viewModel.selectedDestinationName.color(UIColor.by(.white100)))
                        .all.fontName("Roboto-Light").size(12).attributedText
        }
        return (self.viewModel.basketTotalExpensesTitle.color(UIColor.by(.white40))
                + self.viewModel.basketTotalExpenses.color(UIColor.by(.white100))
                + self.viewModel.basketTotalTitle.color(UIColor.by(.white40))
                + self.viewModel.basketTotal.color(UIColor.by(.white100)))
                .all.fontName("Roboto-Light").size(12).attributedText
    }
    
    func didTapTitle() {
        showBalance()
    }
    
    func updateBudgetUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.expenseSourcesAmountLabel.text = self.viewModel.expenseSourcesAmountRounded
            self.basketTotalLabel.attributedText = self.total
        })
    }
    
    func updateTotalUI(animated: Bool) {
        func update() {
            basketTotalLabel.attributedText = total            
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
