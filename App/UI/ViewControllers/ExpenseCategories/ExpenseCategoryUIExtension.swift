//
//  ExpenseCategoryUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ExpenseCategoryEditViewController {    
    func updateIconUI() {
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        tableController.iconView.tintColor = UIColor.by(.textFFFFFF)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.textField.text = viewModel.name
        tableController.monthlyPlannedField.moneyTextField.text = viewModel.monthlyPlanned
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.textField.text = viewModel.selectedCurrencyName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.monthlyPlannedField.moneyTextField.currency = viewModel.selectedCurrency
    }
    
    func updateIncomeSourceCurrencyUI() {
        tableController.incomeSourceCurrencyField.textField.text = viewModel.selectedIncomeSourceCurrencyName
        tableController.incomeSourceCurrencyField.isEnabled = viewModel.canChangeIncomeSourceCurrency
        tableController.set(cell: tableController.incomeSourceCurrencyCell, hidden: !viewModel.canChangeIncomeSourceCurrency)
    }
    
    func updateReminderUI() {
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder
    }

    func updateRemoveButtonUI() {
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}
