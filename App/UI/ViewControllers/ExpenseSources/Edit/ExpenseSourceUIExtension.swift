//
//  ExpenseSourceUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ExpenseSourceEditViewController {
    func updateIconUI() {
        let placeholderName = "" //viewModel.isGoal ? "wallet-goal-default-icon" : "wallet-default-icon"
        tableController?.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: placeholderName, renderingMode: .alwaysTemplate)
        tableController?.iconView.tintColor = UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 250 / 255.0, alpha: 1)
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrencyName
        tableController.currencyArrow.isHidden = !viewModel.canChangeCurrency
        tableController.amountField.currency = viewModel.selectedCurrency
        tableController.goalAmountField.currency = viewModel.selectedCurrency
        tableController.creditLimitField.currency = viewModel.selectedCurrency
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.typeSwitchCell, hidden: viewModel.isNew, animated: animated, reload: false)
//        tableController?.setTypeSwitch(hidden: !viewModel.isNew, animated: animated, reload: false)
//        tableController?.setAmount(hidden: viewModel.amountHidden, animated: animated, reload: false)
//        tableController?.setGoalAmount(hidden: !viewModel.isGoal, animated: animated, reload: false)
//        tableController?.setCreditLimit(hidden: viewModel.creditLimitHidden, animated: animated, reload: false)
//        tableController?.setBankButton(hidden: viewModel.bankButtonHidden, animated: animated, reload: false)
//        tableController?.updateTabsAppearence()
        tableController?.reloadData(animated: animated)
    }
    
    func updateTextFieldsUI() {
//        tableController.nameField.text = viewModel.name
        tableController.amountField.text = viewModel.amount
        tableController.goalAmountField.text = viewModel.goalAmount
        tableController.creditLimitField.text = viewModel.creditLimit
        
        tableController.amountField.isUserInteractionEnabled = viewModel.canChangeAmount
    }
    
    func updateBankUI() {
        
    }
    
    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.isNew)
    }
}

