//
//  AccountsViewModel.swift
//  Capitalist
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
    
    private var accountViewModels: [AccountViewModel] = []
    
    var numberOfAccounts: Int {
        return accountViewModels.count
    }
    
    var expenseSource: ExpenseSource? = nil
//    var currencyCode: String? = nil
//    var nature: AccountNatureType = .account
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func loadAccounts() -> Promise<Void> {
        guard   let connectionId = expenseSource?.accountConnection?.connection.saltedgeId,
                let providerId = expenseSource?.accountConnection?.connection.providerId else {
            return Promise(error: AccountsLoadingError.canNotLoadAccounts)
        }
        
        var currencyCode: String? = nil
        if let expenseSource = expenseSource,
           expenseSource.hasTransactions {
            currencyCode = expenseSource.currency.code
        }
        return  firstly {
                    bankConnectionsCoordinator.loadAccounts(currencyCode: currencyCode,
                                                            connectionId: connectionId,
                                                            providerId: providerId,
                                                            notUsed: true,
                                                            nature: .account)
                }.then { accounts -> Promise<[AccountViewModel]> in
                    
                    guard accounts.count > 0 else {
                        return Promise(error: BankConnectionError.allBankAccountsAlreadyUsed)
                    }
                    let accountViewModels = accounts.map { AccountViewModel(account: $0) }
                    return Promise.value(accountViewModels)
                }.get { accountViewModels in
                    self.accountViewModels = accountViewModels
                }.asVoid()
    }
    
    func accountViewModel(at indexPath: IndexPath) -> AccountViewModel? {
        return accountViewModels[safe: indexPath.row]
    }
}