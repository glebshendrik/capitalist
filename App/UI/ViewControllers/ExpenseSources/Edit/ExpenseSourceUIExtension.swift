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
        tableController.accountTypeLabel.isHidden = true
        tableController.iconPen.isHidden = viewModel.iconPenHidden
        tableController.iconView.isHidden = viewModel.customIconHidden
        tableController.bankIconView.isHidden = viewModel.bankIconHidden
        
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.textFFFFFF)
        
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
            ? UIColor.by(.gray7984A4)
            : UIColor.by(.blue5B86F7)        
        tableController.bankButton.setTitle(viewModel.bankButtonTitle, for: .normal)
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}

