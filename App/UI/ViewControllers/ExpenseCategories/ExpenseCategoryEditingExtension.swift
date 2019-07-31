//
//  ExpenseCategoryEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ExpenseCategoryEditViewController : ExpenseCategoryEditTableControllerDelegate {
    func didTapIcon() {
        push(factory.iconsViewController(delegate: self, iconCategory: viewModel.iconCategory))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(monthlyPlanned: String?) {
        viewModel.monthlyPlanned = monthlyPlanned
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        let delegate =  ExpenseCategoryCurrencyDelegate(delegate: self)
        push(factory.currenciesViewController(delegate: delegate))
    }
    
    func didTapIncomeSourceCurrency() {
        guard viewModel.canChangeIncomeSourceCurrency else { return }
        let delegate =  IncomeSourceDependantCurrencyDelegate(delegate: self)
        push(factory.currenciesViewController(delegate: delegate))
    }
    
    func didTapSetReminder() {
        present(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
    }
}

extension ExpenseCategoryEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        updateIconUI()
    }
}

extension ExpenseCategoryEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminderViewModel = reminderViewModel
        updateReminderUI()
    }
}

class IncomeSourceDependantCurrencyDelegate : CurrenciesViewControllerDelegate {
    let delegate: ExpenseCategoryEditViewController?
    
    init(delegate: ExpenseCategoryEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelectCurrency(currency: Currency) {
        delegate?.update(incomeSourceCurrency: currency)
    }
}

class ExpenseCategoryCurrencyDelegate : CurrenciesViewControllerDelegate {
    let delegate: ExpenseCategoryEditViewController?
    
    init(delegate: ExpenseCategoryEditViewController?) {
        self.delegate = delegate
    }
    
    func didSelectCurrency(currency: Currency) {
        delegate?.update(currency: currency)
    }
}

extension ExpenseCategoryEditViewController {
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency        
        updateCurrencyUI()
    }
    
    func update(incomeSourceCurrency: Currency) {
        viewModel.selectedIncomeSourceCurrency = incomeSourceCurrency
        updateIncomeSourceCurrencyUI()
    }
}
