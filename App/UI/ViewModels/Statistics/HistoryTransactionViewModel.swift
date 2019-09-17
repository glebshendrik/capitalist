//
//  HistoryTransactionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class HistoryTransactionViewModel {
    let historyTransaction: HistoryTransaction
    
    var sourceId: Int {
        return historyTransaction.sourceId
    }
    
    var sourceType: HistoryTransactionSourceOrDestinationType {
        return historyTransaction.sourceType
    }
    
    var sourceTitle: String {
        return historyTransaction.sourceTitle
    }
    
    var destinationId: Int {
        return historyTransaction.destinationId
    }
    
    var destinationType: HistoryTransactionSourceOrDestinationType {
        return historyTransaction.destinationType
    }
    
    var destinationTitle: String {
        return historyTransaction.destinationTitle
    }
    
    var destinationIconURL: URL? {
        return historyTransaction.destinationIconURL
    }
    
    var transactionableId: Int {
        return historyTransaction.transactionableId
    }
    
    var transactionableType: TransactionableType {
        return historyTransaction.transactionableType
    }
    
    var currency: Currency {
        return historyTransaction.currency
    }
    
    var amountCents: Int {
        return historyTransaction.amountCents
    }
    
    var convertedCurrency: Currency {
        return historyTransaction.convertedCurrency
    }
    
    var convertedAmountCents: Int {
        return historyTransaction.convertedAmountCents
    }
    
    var calculatingCurrency: Currency {
        switch transactionableType {
        case .income:
            return convertedCurrency
        case .fundsMove:
            return convertedCurrency
        case .expense:
            return currency
        }
    }
    
    var calculatingAmountCents: Int {
        switch transactionableType {
        case .income:
            return convertedAmountCents
        case .fundsMove:
            return convertedAmountCents
        case .expense:
            return amountCents
        }
    }
    
    var gotAt: Date {
        return historyTransaction.gotAt
    }
    
    var amount: String {        
        guard let transactionAmount = calculatingAmountCents.moneyCurrencyString(with: calculatingCurrency, shouldRound: false) else { return "" }
        switch transactionableType {
        case .income:
            return "+\(transactionAmount)"
        case .fundsMove:
            return transactionAmount
        case .expense:
            return "-\(transactionAmount)"
        }
    }
    
    var comment: String? {
        return historyTransaction.comment
    }
    
    var basketType: BasketType? {
        return historyTransaction.basketType
    }
    
    var includedInBalance: Bool {
        return historyTransaction.includedInBalance ?? false
    }
    
    var borrowId: Int? {
        return historyTransaction.borrowId
    }
    
    var borrowType: BorrowType? {
        return historyTransaction.borrowType
    }
    
    init(historyTransaction: HistoryTransaction) {
        self.historyTransaction = historyTransaction
    }
}
