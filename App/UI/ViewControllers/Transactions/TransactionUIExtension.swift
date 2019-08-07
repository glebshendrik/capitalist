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
    
    @objc func updateDebtUI() {
        tableController.set(cell: tableController.debtCell, hidden: true, animated: false, reload: false)
        tableController.set(cell: tableController.returnCell, hidden: true, animated: false, reload: true)
    }
    
    func updateStartableUI() {
        tableController.sourceField.placeholder = viewModel.startableTitle
        tableController.sourceField.text = viewModel.startableName
        tableController.sourceField.subValue = viewModel.startableAmount
        tableController.sourceField.imageName = viewModel.startableIconDefaultImageName
        tableController.sourceField.imageURL = viewModel.startableIconURL
    }
    
    func updateCompletableUI() {
        tableController.destinationField.placeholder = viewModel.completableTitle
        tableController.destinationField.text = viewModel.completableName
        tableController.destinationField.subValue = viewModel.completableAmount
        tableController.destinationField.imageName = viewModel.completableIconDefaultImageName
        tableController.destinationField.imageURL = viewModel.completableIconURL
    }
    
    func updateAmountUI() {
        tableController.amountField.text = viewModel.amount
        tableController.amountField.placeholder = viewModel.completableAmountTitle
        tableController.amountField.subValue = viewModel.completableCurrencyCode
        tableController.amountField.currency = viewModel.startableCurrency
        tableController.set(cell: tableController.amountCell, hidden: viewModel.needCurrencyExchange, animated: false, reload: true)
    }
    
    func updateExchangeAmountsUI() {
        tableController.exchangeField.amount = viewModel.amount
        tableController.exchangeField.amountPlaceholder = viewModel.amountPlaceholder
        tableController.exchangeField.currency = viewModel.startableCurrency
        tableController.exchangeField.convertedAmount = viewModel.convertedAmount
        tableController.exchangeField.convertedAmountPlaceholder = viewModel.convertedAmountPlaceholder
        tableController.exchangeField.convertedCurrency = viewModel.completableCurrency
        tableController.set(cell: tableController.exchangeCell, hidden: !viewModel.needCurrencyExchange, animated: false, reload: true)
    }
    
    @objc func updateInBalanceUI() {
        tableController.set(cell: tableController.inBalanceCell, hidden: true, animated: false, reload: true)
    }
}
