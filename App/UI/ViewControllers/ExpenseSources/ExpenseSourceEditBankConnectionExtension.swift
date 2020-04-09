//
//  ExpenseSourceEditBankConnectionExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension ExpenseSourceEditViewController : ProvidersViewControllerDelegate, AccountsViewControllerDelegate {
    func showProviders() {
        slideUp(factory.providersViewController(delegate: self))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, providerConnection: ProviderConnection) {
        showAccountsViewController(for: providerConnection)
    }
    
    func showAccountsViewController(for providerConnection: ProviderConnection) {
        let currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrencyCode
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
