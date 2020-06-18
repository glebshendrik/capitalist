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
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.incomeSourceViewModel, destination: nil, transactionType: .income))
        case ActiveInfoField.transactionInvest.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: nil, destination: viewModel?.activeViewModel, transactionType: .fundsMove))
        case ActiveInfoField.transactionSell.identifier:
            modal(factory.transactionEditViewController(delegate: self, source: viewModel?.activeViewModel, destination: nil, transactionType: .fundsMove))
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
        guard let providersViewController = factory.providersViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: providersViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel?, connection: Connection) {
        showAccountsViewController(for: connection)
    }
    
    func showAccountsViewController(for connection: Connection) {
        let currencyCode = viewModel.activeViewModel?.currency.code        
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
