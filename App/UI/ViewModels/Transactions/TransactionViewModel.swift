//
//  TransactionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class TransactionViewModel {
    let transaction: Transaction
    
    var id: Int {
        return transaction.id
    }
    
    var type: TransactionType {
        return transaction.type
    }
    
    var sourceId: Int {
        return transaction.sourceId
    }
    
    var sourceType: TransactionableType {
        return transaction.sourceType
    }
    
    var sourceTitle: String {
        return transaction.sourceTitle
    }
    
    var sourceIconURL: URL? {
        return transaction.sourceIconURL
    }
    
    var destinationId: Int {
        return transaction.destinationId
    }
    
    var destinationType: TransactionableType {
        return transaction.destinationType
    }
    
    var destinationTitle: String {
        return transaction.destinationTitle
    }
    
    var destinationIconURL: URL? {
        return transaction.destinationIconURL
    }
    
    var iconBackgroundImageName: String? {
        return nil
    }
        
//    var amount: String {
//        return amountCents.moneyCurrencyString(with: currency, shouldRound: false) ?? ""
//    }
    
//    var convertedAmount: String {
//        return convertedAmountCents.moneyCurrencyString(with: convertedCurrency, shouldRound: false) ?? ""
//    }
        
    var gotAt: Date {
        return transaction.gotAt
    }
    
    var gotAtFormatted: String {
        return gotAt.dateString(ofStyle: .short)
    }
    
    var comment: String? {
        return transaction.comment
    }
    
    var isDebt: Bool {
        return !isReturn && transaction.borrow?.type == .debt
    }
    
    var isLoan: Bool {
        return !isReturn && transaction.borrow?.type == .loan
    }
    
    var isReturn: Bool {
        return transaction.returningBorrow != nil
    }
    
    var currency: Currency {
        return transaction.currency
    }
    
    var amountCents: Int {
        return transaction.amountCents
    }
    
    var convertedCurrency: Currency {
        return transaction.convertedCurrency
    }
    
    var convertedAmountCents: Int {
        return transaction.convertedAmountCents
    }
            
    var calculatingCurrency: Currency {
        switch type {
        case .income:
            return convertedCurrency
        case .fundsMove:
            return convertedCurrency
        case .expense:
            return currency
        }
    }
    
    var calculatingAmountCents: Int {
        switch type {
        case .income:
            return convertedAmountCents
        case .fundsMove:
            return convertedAmountCents
        case .expense:
            return amountCents
        }
    }
        
    var amount: String {        
        guard let transactionAmount = calculatingAmountCents.moneyCurrencyString(with: calculatingCurrency, shouldRound: false) else { return "" }
        switch type {
        case .income:
            return "+\(transactionAmount)"
        case .fundsMove:
            return transactionAmount
        case .expense:
            return "-\(transactionAmount)"
        }
    }
        
    var basketType: BasketType? {        
        return transaction.basketType
    }
        
    var borrowId: Int? {
        return transaction.borrow?.id
    }
    
    var borrowType: BorrowType? {
        return transaction.borrow?.type
    }
    
    var creditId: Int? {
        return transaction.credit?.id
    }
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
}
