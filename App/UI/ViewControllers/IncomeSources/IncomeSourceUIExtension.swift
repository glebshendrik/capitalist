//
//  IncomeSourceUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension IncomeSourceEditViewController {
    func updateCurrencyUI() {
        tableController.currencyField.textField.text = viewModel.selectedCurrencyName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.textField.text = viewModel.name
    }
    
    func updateReminderUI() {
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder
    }
    
    func updateRemoveButtonUI() {        
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden)
    }
}
