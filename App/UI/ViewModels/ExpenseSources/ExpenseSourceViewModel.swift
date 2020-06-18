//
//  ExpenseSourceViewModel.swift
//  Three Baskets
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
    
    var amountCents: Int {
        return accountViewModel?.amountCents ?? expenseSource.amountCents
    }
    
    var creditLimitCents: Int? {
        return accountViewModel?.creditLimitCents ?? expenseSource.creditLimitCents
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
    
    var iconURL: URL? {
        return accountViewModel?.providerLogoURL ?? expenseSource.iconURL
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
        return accountViewModel?.cardType ?? expenseSource.cardType
    }
    
    var cardTypeImageName: String? {
        return cardType?.imageName
    }
    
    var cardLastNumbers: String? {        
        return accountViewModel?.cardLastNumbers
    }
    
    var accountConnected: Bool {
        return accountViewModel != nil
    }
    
    var reconnectNeeded: Bool {
        return accountViewModel?.reconnectNeeded ?? false
    }
    
    var reconnectType: ProviderConnectionType {
        return accountViewModel?.reconnectType ?? .refresh
    }
    
    var iconHidden: Bool {
        return isConnectionLoading || reconnectNeeded
    }
    
    var reconnectWarningHidden: Bool {
        return !reconnectNeeded || isConnectionLoading
    }
    
    var connectionIndicatorHidden: Bool {
        return !isConnectionLoading
    }
    
    init(expenseSource: ExpenseSource) {
        self.expenseSource = expenseSource
        if let account = expenseSource.accountConnection?.account {
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

extension ExpenseSourceViewModel : TransactionSource, TransactionDestination {
    var type: TransactionableType {
        return .expenseSource
    }
    
    var iconCategory: IconCategory? {
        return IconCategory.expenseSource
    }
    
    var isTransactionSource: Bool {
        return true
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        if let sourceExpenseSourceViewModel = transactionSource as? ExpenseSourceViewModel {
            return sourceExpenseSourceViewModel.id != self.id
        }
        
        return (transactionSource is IncomeSourceViewModel) || (transactionSource is ActiveViewModel)
    }
}
