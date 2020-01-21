//
//  ActiveUIExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ActiveEditViewController {
    func update(iconURL: URL) {
        viewModel.selectedIconURL = iconURL
        updateIconUI()
    }
    
    func update(activeType: ActiveTypeViewModel) {
        viewModel.selectedActiveType = activeType
        updateActiveTypeUI()
        updateActiveIncomeTypeUI()
        updateTextFieldsUI()
        updateIsIncomePlannedUI()
        updateTableUI()
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
    
    func update(activeIncomeType: ActiveIncomeType) {
        viewModel.selectedActiveIncomeType = activeIncomeType
        updateActiveIncomeTypeUI()
        updateTableUI(animated: false)
    }
        
    func update(reminder: ReminderViewModel) {
        viewModel.reminderViewModel = reminder
        updateReminderUI()
    }
}

extension ActiveEditViewController {
    func updateIconUI() {
        tableController.iconView.setImage(with: viewModel.selectedIconURL, placeholderName: viewModel.iconDefaultImageName, renderingMode: .alwaysTemplate)        
        tableController.iconBackgroundView.backgroundColor = viewModel.basketType.iconBackgroundColor        
        tableController.iconView.tintColor = UIColor.by(.white100)
    }
    
    func updateTextFieldsUI() {
        tableController.nameField.text = viewModel.name
        
        tableController.costField.text = viewModel.cost
        tableController.costField.placeholder = viewModel.costTitle
        tableController.costField.currency = viewModel.selectedCurrency
        
        tableController.alreadyPaidField.text = viewModel.alreadyPaid
        tableController.alreadyPaidField.currency = viewModel.selectedCurrency
        
        tableController.goalAmountField.text = viewModel.goal
        tableController.goalAmountField.currency = viewModel.selectedCurrency
        
        tableController.monthlyPaymentField.text = viewModel.monthlyPayment
        tableController.monthlyPaymentField.placeholder = viewModel.monthlyPaymentTitle
        tableController.monthlyPaymentField.currency = viewModel.selectedCurrency
        
        tableController.annualPercentField.text = viewModel.annualPercent
        
        tableController.monthlyPlannedIncomeField.text = viewModel.monthlyPlannedIncome
        tableController.monthlyPlannedIncomeField.currency = viewModel.selectedCurrency
    }
        
    func updateActiveTypeUI() {
        tableController.activeTypeField.text = viewModel.selectedActiveType?.name
        tableController.activeTypeField.isEnabled = viewModel.canChangeActiveType
    }
    
    func updateCurrencyUI() {
        tableController.currencyField.text = viewModel.selectedCurrency?.translatedName
        tableController.currencyField.isEnabled = viewModel.canChangeCurrency
        
        tableController.costField.currency = viewModel.selectedCurrency
        tableController.alreadyPaidField.currency = viewModel.selectedCurrency
        tableController.goalAmountField.currency = viewModel.selectedCurrency
        tableController.monthlyPaymentField.currency = viewModel.selectedCurrency
        tableController.monthlyPlannedIncomeField.currency = viewModel.selectedCurrency
    }
    
    func updateIsIncomePlannedUI() {
        tableController.plannedIncomeSwitchField.value = viewModel.isIncomePlanned    
    }
    
    func updateActiveIncomeTypeUI() {
        tableController.activeIncomeTypeField.text = viewModel.selectedActiveIncomeType?.title
    }
    
    func updateReminderUI() {
        tableController.set(cell: tableController.reminderCell, hidden: viewModel.reminderHidden, animated: false, reload: false)
        tableController.reminderLabel.isHidden = viewModel.reminderHidden
        tableController.reminderButton.setTitle(viewModel.reminderTitle, for: .normal)
        tableController.reminderLabel.text = viewModel.reminder
    }
        
    func updateRemoveButtonUI(reload: Bool = false, animated: Bool = false) {
        tableController.removeButton.setTitle("Удалить актив", for: .normal)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: animated, reload: reload)
    }
    
    func updateTableUI(animated: Bool = true) {
        tableController.set(cell: tableController.activeIncomeTypeCell, hidden: viewModel.activeIncomeTypeFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.alreadyPaidCell, hidden: viewModel.alreadyPaidFieldHidden, animated: animated, reload: false)
        tableController.set(cell: tableController.goalAmountCell, hidden: viewModel.goalAmountFieldHidden, animated: animated, reload: false)
        tableController.set(cell: tableController.monthlyPlannedIncomeCell, hidden: viewModel.monthlyPlannedIncomeFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.annualPercentCell, hidden: viewModel.annualPercentFieldHidden, animated: false, reload: false)
        tableController.set(cell: tableController.reminderCell, hidden: viewModel.reminderHidden, animated: false, reload: false)
        tableController.set(cell: tableController.removeCell, hidden: viewModel.removeButtonHidden, animated: false, reload: false)
        tableController.reloadData(animated: animated)
    }
}
