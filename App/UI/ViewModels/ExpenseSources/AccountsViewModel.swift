//
//  AccountsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum AccountsLoadingError : Error {
    case canNotLoadAccounts
}

class AccountsViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    private let currenciesCoordinator: CurrenciesCoordinatorProtocol
    
    private var accountViewModels: [AccountViewModel] = []
    
    var numberOfAccounts: Int {
        return accountViewModels.count
    }
    
    var providerConnection: ProviderConnection? = nil
    var currencyCode: String? = nil
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol,
         currenciesCoordinator: CurrenciesCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        self.currenciesCoordinator = currenciesCoordinator
    }
    
    func loadAccounts() -> Promise<Void> {
        guard let providerConnection = providerConnection else {
            return Promise(error: AccountsLoadingError.canNotLoadAccounts)
        }
        
        return  firstly {
                    when(fulfilled: bankConnectionsCoordinator.loadAvailableSaltEdgeAccounts(for: providerConnection, currencyCode: currencyCode),
                         currenciesCoordinator.hash())            
                }.then { accounts, currencies -> Promise<[AccountViewModel]> in
                    
                    let accountViewModels: [AccountViewModel] = accounts.compactMap { account in
                        
                        guard let currency = currencies[account.currencyCode] else { return nil }
                        
                        return AccountViewModel(account: account,                                         
                                                currency: currency)
                    }
                    
                    if accountViewModels.count == 0 {
                        return Promise(error: BankConnectionError.allBankAccountsAlreadyUsed)
                    }
                    return Promise.value(accountViewModels)
                    
                }.get { accountViewModels in
                    self.accountViewModels = accountViewModels
                }
                .asVoid()
    }
    
    func accountViewModel(at indexPath: IndexPath) -> AccountViewModel? {
        return accountViewModels.item(at: indexPath.row)
    }
}
