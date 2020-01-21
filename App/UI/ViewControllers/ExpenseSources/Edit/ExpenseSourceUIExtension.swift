//
//  ExpenseSourceUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SDWebImageSVGCoder

extension ExpenseSourceEditViewController {
    func updateIconUI() {
        tableController.iconPen.isHidden = viewModel.iconPenHidden
        tableController.iconView.isHidden = viewModel.customIconHidden
        tableController.bankIconView.isHidden = viewModel.bankIconHidden
        
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.white100)
        
        tableController.bankIconView.sd_setImage(with: viewModel.selectedIconURL, completed: nil)
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrencyName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.amountField.currency = viewModel.selectedCurrency
        tableController.creditLimitField.currency = viewModel.selectedCurrency
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: animated, reload: false)
        tableController.set(cell: tableController.bankCell, hidden: true, animated: animated, reload: false)
        tableController.reloadData(animated: animated)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        tableController.amountField.text = viewModel.amount
        tableController.creditLimitField.text = viewModel.creditLimit        
        tableController.amountField.isEnabled = viewModel.canChangeAmount
    }
    
    func updateBankUI() {
        tableController.bankButton.backgroundColor = viewModel.accountConnected
            ? UIColor.by(.gray1)
            : UIColor.by(.blue1)        
        tableController.bankButton.setTitle(viewModel.bankButtonTitle, for: .normal)
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}

