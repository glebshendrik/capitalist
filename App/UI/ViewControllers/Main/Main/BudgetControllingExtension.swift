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
            return (viewModel.selectedSourceName.color(UIColor.by(.text9EAACC))
                    + " - ".color(UIColor.by(.text9EAACC))
                    + viewModel.selectedDestinationName.color(UIColor.by(.text9EAACC)))
                        .all.fontName("Rubik-Regular").size(13).attributedText
        }
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
