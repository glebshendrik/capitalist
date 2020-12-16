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
        guard let providersViewController = factory.providersViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: providersViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel?, connection: Connection) {
        showAccountsViewController(for: connection)
    }
    
    func showAccountsViewController(for connection: Connection) {
        let currencyCode = viewModel.isNew ? nil : viewModel.selectedCurrencyCode
        slideUp(factory.accountsViewController(delegate: self,
                                               connection: connection,
                                               currencyCode: currencyCode,
                                               nature: .account))
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
