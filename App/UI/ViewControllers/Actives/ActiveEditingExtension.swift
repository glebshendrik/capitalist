//
//  ActiveEditingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension ActiveEditViewController : ActiveEditTableControllerDelegate {
    func didAppear() {
        focusFirstEmptyField()
    }
    
    func didTapIcon() {
        modal(factory.iconsViewController(delegate: self, iconCategory: viewModel.basketType.iconCategory))
    }
    
    func didTapActiveType() {
        guard viewModel.canChangeActiveType else { return }
        showActiveTypesSheet()
    }

    func didChange(name: String?) {
        viewModel.name = name
    }
    
    func didTapCurrency() {
        guard viewModel.canChangeCurrency else { return }
        modal(factory.currenciesViewController(delegate: self))
    }
    
    func didChange(cost: String?) {
        viewModel.cost = cost
        updateTextFieldsUI()
    }
    
    func didChange(alreadyPaid: String?) {
        viewModel.alreadyPaid = alreadyPaid
    }
    
    func didChange(goalAmount: String?) {
        viewModel.goal = goalAmount
    }
    
    func didChange(monthlyPayment: String?) {
        viewModel.monthlyPayment = monthlyPayment
    }
    
    func didChange(isIncomePlanned: Bool) {
        viewModel.isIncomePlanned = isIncomePlanned
        updateTableUI(animated: false)
    }
    
    func didTapActiveIncomeType() {
        showActiveIncomeTypesSheet()
    }
    
    func didChange(annualPercent: String?) {
        viewModel.annualPercent = annualPercent
    }
    
    func didChange(monthlyPlannedIncome: String?) {
        viewModel.monthlyPlannedIncome = monthlyPlannedIncome
    }
    
    func didTapSetReminder() {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminderViewModel))
    }
    
    func didTapSave() {
        save()
    }
    
    func didTapBankButton() {
        if viewModel.accountConnected {
            removeAccountConnection()
        } else {
            showProviders()
        }
    }
}

extension ActiveEditViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        update(iconURL: icon.url)
    }
}

extension ActiveEditViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
}

extension ActiveEditViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        update(reminder: reminderViewModel)
    }
}

extension ActiveEditViewController {
    private func showActiveTypesSheet() {
        let actions = viewModel.activeTypes.map { activeType in
            return UIAlertAction(title: activeType.name,
                                 style: .default,
                                 handler: { _ in
                                    self.update(activeType: activeType)
            })
        }
        sheet(title: nil, actions: actions)
    }
    
    private func showActiveIncomeTypesSheet() {
        let actions = [ActiveIncomeType.annualPercents, ActiveIncomeType.monthlyIncome].map { activeIncomeType in
            return UIAlertAction(title: activeIncomeType.title,
                                 style: .default,
                                 handler: { _ in
                                    self.update(activeIncomeType: activeIncomeType)
            })
        }        
        sheet(title: nil, actions: actions)
    }
}

extension ActiveEditViewController : ProvidersViewControllerDelegate, AccountsViewControllerDelegate {
    func showProviders() {
        slideUp(factory.providersViewController(delegate: self))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, providerConnection: ProviderConnection) {
        showAccountsViewController(for: providerConnection)
    }
    
    func showAccountsViewController(for providerConnection: ProviderConnection) {
        let currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrency?.code
        slideUp(factory.accountsViewController(delegate: self,
                                               providerConnection: providerConnection,
                                               currencyCode: currencyCode))
    }
    
    func didSelect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        connect(accountViewModel, providerConnection)
    }
    
    func connect(_ accountViewModel: AccountViewModel, _ providerConnection: ProviderConnection) {
        viewModel.connect(accountViewModel: accountViewModel, providerConnection: providerConnection)
        updateUI()
    }
    
    func removeAccountConnection() {
        viewModel.removeAccountConnection()
        updateUI()
    }
}
