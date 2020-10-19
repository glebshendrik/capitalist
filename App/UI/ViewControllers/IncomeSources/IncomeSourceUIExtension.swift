//
//  IncomeSourceUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension IncomeSourceEditViewController {
    func focusFirstEmptyField() {
        if viewModel.name == nil && isCurrentTopmostPresentedViewController {
            tableController.nameField.textField.becomeFirstResponder()            
        }
    }
    
    func updateIconUI() {
        tableController.icon.iconURL = viewModel.selectedIconURL
        tableController.icon.defaultIconName = viewModel.defaultIconName
        tableController.icon.vectorIconMode = .fullsize
        tableController.icon.iconTintColor = UIColor.by(.white100)
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrencyName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        tableController.monthlyPlannedField.currency = viewModel.selectedCurrency
    }
    
    func updateTextFieldsUI() {        
        tableController.nameField.text = viewModel.name
        tableController.monthlyPlannedField.text = viewModel.monthlyPlanned
        tableController.monthlyPlannedField.isEnabled = viewModel.canChangeMonthlyPlanned
    }
    
    func updateReminderUI() {
        tableController.set(cell: tableController.reminderCell, hidden: viewModel.reminderHidden, animated: false, reload: false)
        tableController.reminderLabel.isHidden = viewModel.reminderHidden
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder        
    }
    
    func updateRemoveButtonUI() {        
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: false, reload: false)
    }
}
