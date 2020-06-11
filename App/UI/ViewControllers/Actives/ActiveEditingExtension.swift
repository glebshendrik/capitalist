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
    
    func didTapExpenseSource() {
        slideUp(factory.expenseSourceSelectViewController(delegate: self,
                                                          skipExpenseSourceId: nil,
                                                          selectionType: .destination,
                                                          currency: viewModel.selectedCurrency?.code))
    }
        
    func didChange(isMovingFundsFromWallet: Bool) {
        viewModel.isMovingFundsFromWallet = isMovingFundsFromWallet
        updateExpenseSourceUI(reload: true, animated: false)
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

extension ActiveEditViewController : ExpenseSourcesViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: sourceExpenseSourceViewModel)
    }
    
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel) {
        update(expenseSource: destinationExpenseSourceViewModel)
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
        guard let providersViewController = factory.providersViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: providersViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, connection: Connection) {
        showAccountsViewController(for: connection)
    }
    
    func showAccountsViewController(for connection: Connection) {
        let currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrency?.code
        slideUp(factory.accountsViewController(delegate: self,
                                               connection: connection,
                                               currencyCode: currencyCode,
                                               nature: .investment))
    }
    
    func didSelect(accountViewModel: AccountViewModel, connection: Connection) {
        connect(accountViewModel, connection)
    }
    
    func connect(_ accountViewModel: AccountViewModel, _ connection: Connection) {
        viewModel.connect(accountViewModel: accountViewModel, connection: connection)
        updateUI()
    }
    
    func removeAccountConnection() {
        viewModel.removeAccountConnection()
        updateUI()
    }
}
