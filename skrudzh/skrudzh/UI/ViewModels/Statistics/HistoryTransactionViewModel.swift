//
//  HistoryTransactionViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
    
    var gotAt: Date {
        return historyTransaction.gotAt
    }
    
    var amount: String {        
        guard let transactionAmount = amountCents.moneyCurrencyString(with: currency, shouldRound: false) else { return "" }
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
    
    init(historyTransaction: HistoryTransaction) {
        self.historyTransaction = historyTransaction
    }
}
