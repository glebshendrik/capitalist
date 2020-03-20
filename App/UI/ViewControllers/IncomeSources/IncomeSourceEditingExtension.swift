//
//  IncomeSourceEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension IncomeSourceEditViewController : IncomeSourceEditTableControllerDelegate {
    func didAppear() {        
        focusFirstEmptyField()
    }
    
    func didTapIcon() {
        modal(factory.iconsViewController(delegate: self, iconCategory: IconCategory.common))
    }
    
    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        modal(factory.currenciesViewController(delegate: self))
    }
    
    func didChange(monthlyPlanned: String?) {
        viewModel.monthlyPlanned = monthlyPlanned
    }
    
    func didTapSetReminder() {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
    }
    
    func didTapSave() {
        save()
    }
}

extension IncomeSourceEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url        
        updateIconUI()
    }
}

extension IncomeSourceEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        viewModel.selectedCurrency = currency
        updateCurrencyUI()
    }
}

extension IncomeSourceEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminderViewModel = reminderViewModel
        updateReminderUI()
    }
}
