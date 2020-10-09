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
    func focusFirstEmptyField() {
        if viewModel.name == nil {
            tableController.nameField.textField.becomeFirstResponder()
        }
        else {
            tableController.amountField.textField.becomeFirstResponder()
        }
    }
    
    func updateIconUI() {
        tableController.iconPen.isHidden = viewModel.iconPenHidden
        
        tableController.icon.iconURL = viewModel.selectedIconURL
        tableController.icon.defaultIconName = viewModel.defaultIconName
        tableController.icon.vectorIconMode = .fullsize
        tableController.icon.iconTintColor = UIColor.by(.white100)        
    }
    
    func updateCardTypeUI() {
        tableController.cardTypeField.valueImageName = viewModel.selectedCardTypeImageName
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
//        tableController.bankButton.setTitle(viewModel.bankButtonTitle, for: .normal)
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}

