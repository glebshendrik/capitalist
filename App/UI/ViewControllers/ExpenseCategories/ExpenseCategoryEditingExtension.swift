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
        modal(factory.iconsViewController(delegate: self, iconCategory: viewModel.basketType.iconCategory))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didChange(monthlyPlanned: String?) {
        viewModel.monthlyPlanned = monthlyPlanned
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        modal(factory.currenciesViewController(delegate: self))
    }
        
    func didTapSetReminder() {        
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
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

extension ExpenseCategoryEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
}

extension ExpenseCategoryEditViewController {
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency        
        updateCurrencyUI()
    }
}
