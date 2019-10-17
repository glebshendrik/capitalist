//
//  TransactionUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension TransactionEditViewController {
    func updateToolbarUI() {
        UIView.transition(with: view, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.tableController.calendarButton.setTitle(self.viewModel.calendarTitle, for: .normal)
        })
    }
        
    func updateSourceUI() {
        tableController.sourceField.placeholder = viewModel.sourceTitle
        tableController.sourceField.text = viewModel.sourceName
        tableController.sourceField.subValue = viewModel.sourceAmount
        tableController.sourceField.imageName = viewModel.sourceIconDefaultImageName
        tableController.sourceField.imageURL = viewModel.sourceIconURL
    }
    
    func updateDestinationUI() {
        tableController.destinationField.placeholder = viewModel.destinationTitle
        tableController.destinationField.text = viewModel.destinationName
        tableController.destinationField.subValue = viewModel.destinationAmount
        tableController.destinationField.imageName = viewModel.destinationIconDefaultImageName
        tableController.destinationField.imageURL = viewModel.destinationIconURL
    }
    
    func updateAmountUI() {
        tableController.amountField.text = viewModel.amount
        tableController.amountField.placeholder = viewModel.destinationAmountTitle
        tableController.amountField.subValue = viewModel.destinationCurrencyCode
        tableController.amountField.currency = viewModel.sourceCurrency
        tableController.set(cell: tableController.amountCell, hidden: viewModel.amountFieldHidden, animated: false, reload: false)
    }
    
    func updateExchangeAmountsUI() {
        tableController.exchangeField.amount = viewModel.amount
        tableController.exchangeField.amountPlaceholder = viewModel.amountPlaceholder
        tableController.exchangeField.amountSelectedTitle = viewModel.sourceAmountTitle
        tableController.exchangeField.currency = viewModel.sourceCurrency
        tableController.exchangeField.convertedAmount = viewModel.convertedAmount
        tableController.exchangeField.convertedAmountPlaceholder = viewModel.convertedAmountPlaceholder
        tableController.exchangeField.convertedAmountSelectedTitle = viewModel.destinationAmountTitle
        tableController.exchangeField.convertedCurrency = viewModel.destinationCurrency
        tableController.set(cell: tableController.exchangeCell, hidden: viewModel.exchangeAmountsFieldHidden, animated: false, reload: false)
    }
        
    func updateInBalanceUI() {
        tableController.inBalanceSwitchField.value = viewModel.includedInBalance
        tableController.set(cell: tableController.inBalanceCell, hidden: viewModel.includedInBalanceFieldHidden, animated: false, reload: false)        
    }
    
    func updateCommentUI() {
        tableController.commentView.text = viewModel.comment
    }
    
    func updateRemoveButtonUI() {
        tableController.removeButton.setTitle(viewModel.removeTitle, for: .normal)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}
