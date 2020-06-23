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
    
    func update(expenseSource: ExpenseSourceViewModel?) {
        viewModel.selectedSource = expenseSource
        updateExpenseSourceUI(reload: true, animated: false)
    }
}

extension ActiveEditViewController {
    func focusFirstEmptyField() {
        if viewModel.name == nil {
            tableController.nameField.textField.becomeFirstResponder()
        }
        else {
            tableController.costField.textField.becomeFirstResponder()
        }
    }
    
    func updateIconUI() {
        tableController.iconPen.isHidden = viewModel.iconPenHidden
        tableController.icon.iconURL = viewModel.selectedIconURL
        tableController.icon.defaultIconName = viewModel.iconDefaultImageName
        tableController.icon.backgroundColor = viewModel.basketType.iconBackgroundColor
        tableController.icon.vectorIconMode = .fullsize
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
    
    func updateExpenseSourceUI(reload: Bool = false, animated: Bool = false) {
        tableController.set(cell: tableController.isMovingFundsFromWalletCell, hidden: viewModel.movingFundsFromWalletSelectionHidden, animated: false, reload: false)
        tableController.isMovingFundsFromWalletSwitchField.value = viewModel.isMovingFundsFromWallet
                
        tableController.set(cell: tableController.expenseSourceCell, hidden: viewModel.expenseSourceFieldHidden, animated: false, reload: false)
        tableController.expenseSourceField.placeholder = "Кошелек"
        tableController.expenseSourceField.text = viewModel.expenseSourceName
        tableController.expenseSourceField.subValue = viewModel.expenseSourceAmount
        tableController.expenseSourceField.imageName = viewModel.expenseSourceIconDefaultImageName
        tableController.expenseSourceField.imageURL = viewModel.expenseSourceIconURL
        if reload {
            tableController.reloadData(animated: animated)
        }
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
        tableController.removeButton.setTitle(NSLocalizedString("Удалить актив", comment: "Удалить актив"), for: .normal)
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
        tableController.set(cell: tableController.bankCell, hidden: true, animated: animated, reload: false)
        tableController.reloadData(animated: animated)
    }
    
    func updateBankUI() {
        tableController.bankButton.backgroundColor = viewModel.accountConnected
            ? UIColor.by(.gray1)
            : UIColor.by(.blue1)        
        tableController.bankButton.setTitle(viewModel.bankButtonTitle, for: .normal)
    }
}
