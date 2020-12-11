//
//  ExpenseSourceViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

class ExpenseSourceViewModel {
    public private(set) var expenseSource: ExpenseSource
    public private(set) var accountViewModel: AccountViewModel? = nil
    
    var isSelected: Bool = false
    var isConnectionLoading: Bool = false
    
    var id: Int {
        return expenseSource.id
    }
    
    var name: String {
        return expenseSource.name
    }
    
    var prototypeKey: String? {
        return expenseSource.prototypeKey
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var inCredit: Bool {
        guard let creditLimitCents = creditLimitCents else { return false }
        return amountCents < creditLimitCents
    }
    
    var hasCreditLimit: Bool {
        guard let creditLimitCents = creditLimitCents else { return false }
        return creditLimitCents > 0
    }
    
    var creditCents: Int? {
        guard let creditLimitCents = creditLimitCents else { return nil }
        return creditLimitCents - amountCents
    }
    
    var credit: String? {
        return creditCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var creditLimit: String? {
        return creditLimitCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var currency: Currency {
        return expenseSource.currency
    }
    
    var isDeleted: Bool {
        return expenseSource.deletedAt != nil
    }
    
    var isVirtual: Bool {
        return expenseSource.isVirtual
    }
        
    var iconType: IconType {
        return iconURL?.iconType ?? .raster
    }
    
    var cardType: CardType? {
        return expenseSource.cardType
    }
    
    var cardTypeImageName: String? {
        return cardType?.imageName
    }
        
    var fetchDataFrom: Date? {
        return expenseSource.fetchDataFrom
    }
    
    var providerCodes: [String]? {
        return expenseSource.providerCodes
    }
    
    var isTreatedAsUnlinked: Bool {
        return !isVirtual && prototypeKey == nil
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        if let account = accountConnection?.account {
            self.accountViewModel = AccountViewModel(account: account)
        }
    }
    
    func asTransactionFilter() -> ExpenseSourceFilter {
        return ExpenseSourceFilter(expenseSourceViewModel: self)
    }
    
    private func amount(shouldRound: Bool) -> String {
        return amountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}

// Connection dependant properties
extension ExpenseSourceViewModel {
    var accountConnection: AccountConnection? {
        return expenseSource.accountConnection
    }
    
    var connection: Connection? {
        return accountConnection?.connection
    }
    
    var amountCents: Int {
        return accountViewModel?.amountCents ?? expenseSource.amountCents
    }
    
    var creditLimitCents: Int? {
        return accountViewModel?.creditLimitCents ?? expenseSource.creditLimitCents
    }
    
    var iconURL: URL? {
        return providerLogoURL ?? expenseSource.iconURL
    }
    
    var cardLastNumbers: String? {
        return accountViewModel?.cardLastNumbers
    }
    
    var connectionConnected: Bool {
        return connection != nil
    }
    
    var accountConnected: Bool {
        return accountConnection?.account != nil
    }
    
    var connectionId: String? {
        return connection?.saltedgeId
    }
    
    var providerLogoURL: URL? {
        return connection?.providerLogoURL
    }
        
    var reconnectNeeded: Bool {
        return connection?.reconnectNeeded ?? false
    }
    
    var isSyncingWithBank: Bool {
        return connection?.isSyncing ?? false
    }
    
    var syncingWithBankStage: ConnectionStage? {
        return connection?.lastStage
    }
    
    var reconnectType: ConnectionSessionType {
        guard
            let connection = connection
        else {
            return .creating
        }
        switch connection.status {
            case .active:
                return .refreshing
            case .inactive:
                return .reconnecting
            case .deleted:
                return .creating
        }
    }
    
    var iconHidden: Bool {
        return isConnectionLoading || isSyncingWithBank || reconnectNeeded
    }
    
    var reconnectWarningHidden: Bool {
        return isConnectionLoading || isSyncingWithBank || !reconnectNeeded 
    }
    
    var connectionIndicatorHidden: Bool {
        return !isConnectionLoading && !isSyncingWithBank
    }
}

extension ExpenseSourceViewModel : TransactionSource, TransactionDestination {
    var type: TransactionableType {
        return .expenseSource
    }
    
    var iconCategory: IconCategory? {
        return IconCategory.expenseSource
    }
    
    var isTransactionSource: Bool {
        return !accountConnected
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        if accountConnected {
            return false
        }
        if let sourceExpenseSourceViewModel = transactionSource as? ExpenseSourceViewModel {
            return sourceExpenseSourceViewModel.id != self.id
        }
        
        return (transactionSource is IncomeSourceViewModel) || (transactionSource is ActiveViewModel)
    }
}
