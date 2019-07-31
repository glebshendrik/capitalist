//
//  ExpenseSourceEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ExpenseSourceEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
}

extension ExpenseSourceEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
}

extension ExpenseSourceEditViewController : ExpenseSourceEditTableControllerDelegate {
    func didTap(accountType: AccountType) {
        viewModel.accountType = accountType
        updateIconUI()
        updateTableUI()
    }
    
    func didTapIcon() {
        guard viewModel.canChangeIcon else { return }
        push(factory.iconsViewController(delegate: self, iconCategory: viewModel.iconCategory))        
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        push(factory.currenciesViewController(delegate: self))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(amount: String?) {
        viewModel.amount = amount
    }
    
    func didChange(creditLimit: String?) {
        viewModel.creditLimit = creditLimit
        updateTextFieldsUI()
    }
    
    func didChange(goalAmount: String?) {
        viewModel.goalAmount = goalAmount
    }
        
    func didTapBankButton() {
        if viewModel.accountConnected {
            removeAccountConnection()
        } else {
            showProviders()
        }
    }
}
