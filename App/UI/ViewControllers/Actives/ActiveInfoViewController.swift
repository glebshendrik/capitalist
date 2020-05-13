//
//  ActiveInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ActiveInfoViewController : EntityInfoNavigationController {
    var viewModel: ActiveInfoViewModel!
    
    override var entityInfoViewModel: EntityInfoViewModel! {
        return viewModel
    }
        
    override func didTapIcon(field: IconInfoField?) {
        modal(factory.iconsViewController(delegate: self, iconCategory: viewModel.basketType.iconCategory))
    }
        
    override func didTapReminderButton(field: ReminderInfoField?) {
        modal(factory.reminderEditViewController(delegate: self, viewModel: viewModel.reminder))
    }
       
    override func didSwitch(field: SwitchInfoField?) {
        guard let field = field, field.identifier == ActiveInfoField.hasIncomeSwitch.identifier else { return }
        viewModel.isIncomePlanned = field.value
        save()
    }
    
    override func didTapInfoField(field: BasicInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ActiveInfoField.cost.identifier:
            showEditScreen()
        default:
            return
        }
    }
    
    override func didTapInfoButton(field: ButtonInfoField?) {
        guard let field = field else { return }
        switch field.identifier {
        case ActiveInfoField.bank.identifier:
            didTapBankButton()
        case ActiveInfoField.statistics.identifier:
            modal(factory.statisticsModalViewController(filter: viewModel.asFilter()))
        case ActiveInfoField.costChange.identifier:
            showEditScreen()
        case ActiveInfoField.transactionDevidents.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.incomeSourceViewModel, destination: nil))
        case ActiveInfoField.transactionInvest.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.activeViewModel))
        case ActiveInfoField.transactionSell.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.activeViewModel, destination: nil))
        default:
            return
        }
    }
    
    override func showEditScreen() {
        modal(factory.activeEditViewController(delegate: self, active: viewModel.active, basketType: viewModel.basketType, costCents: nil))
    }
    
    func didTapBankButton() {
        if viewModel.accountConnected {
            removeAccountConnection()
        } else {
            showProviders()
        }
    }
    
    override var isSelectingTransactionables: Bool {
        return false
    }
    
    override func didCreateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    override func didUpdateTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
    
    override func didRemoveTransaction(id: Int, type: TransactionType) {
        refreshData()
    }
}

extension ActiveInfoViewController : ProvidersViewControllerDelegate, AccountsViewControllerDelegate {
    func showProviders() {
        slideUp(factory.providersViewController(delegate: self))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, providerConnection: ProviderConnection) {
        showAccountsViewController(for: providerConnection)
    }
    
    func showAccountsViewController(for providerConnection: ProviderConnection) {
        let currencyCode = viewModel.activeViewModel?.currency.code
        slideUp(factory.accountsViewController(delegate: self,
                                               providerConnection: providerConnection,
                                               currencyCode: currencyCode))
    }
    
    func didSelect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        connect(accountViewModel, providerConnection)
    }
    
    func connect(_ accountViewModel: AccountViewModel, _ providerConnection: ProviderConnection) {
        viewModel.connect(accountViewModel: accountViewModel, providerConnection: providerConnection)
        save()
    }
    
    func removeAccountConnection() {
        viewModel.removeAccountConnection()
        save()
    }
}

extension ActiveInfoViewController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        viewModel.selectedIconURL = icon.url
        save()
    }
}

extension ActiveInfoViewController : ReminderEditViewControllerDelegate {
    func didSave(reminderViewModel: ReminderViewModel) {
        viewModel.reminder = reminderViewModel
        save()
    }
}

extension ActiveInfoViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool) {
        
    }
    
    func didUpdateActive(with basketType: BasketType) {
        refreshData()
    }
    
    func didRemoveActive(with basketType: BasketType) {
        viewModel.setAsDeleted()
        closeButtonHandler()
    }
}
