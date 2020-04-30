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
    
    var gotAtStartOfDay: Date {        
        return gotAt.replacing(hour: 0, minute: 0) ?? gotAt.dateAtStartOf(.day)
    }
    
    var gotAtFormatted: String {
        return gotAt.dateString(ofStyle: .short)
    }
    
    var comment: String? {
        return transaction.comment
    }
    
    var isBorrowing: Bool {
        return isDebt || isLoan
    }
    
    var isCrediting: Bool {
        return creditId != nil
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
    
    var isReturningDebt: Bool {
        guard let returningBorrow = transaction.returningBorrow else { return false }
        return returningBorrow.type == .debt
    }
    
    var isReturningLoan: Bool {
        guard let returningBorrow = transaction.returningBorrow else { return false }
        return returningBorrow.type == .loan
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
    
    var removeTitle: String {
        if isCrediting {
            return NSLocalizedString("Удалить кредит со всеми транзакциями?", comment: "Удалить кредит со всеми транзакциями?")
        }
        if isDebt {
            return NSLocalizedString("Удалить долг со всеми транзакциями?", comment: "Удалить долг со всеми транзакциями?")
        }
        if isLoan {
            return NSLocalizedString("Удалить займ со всеми транзакциями?", comment: "Удалить займ со всеми транзакциями?")
        }
        return NSLocalizedString("Удалить транзакцию?", comment: "Удалить транзакцию?")
    }
    
    var typeDescription: String? {
        if isDebt {
            return NSLocalizedString("Вы дали в долг", comment: "")
        }
        if isLoan {
            return NSLocalizedString("Вы взяли займ", comment: "")
        }
        if isReturningDebt {
            return NSLocalizedString("Вам вернули", comment: "")
        }
        if isReturningLoan {
            return NSLocalizedString("Вы вернули", comment: "")
        }
        return comment?.isEmpty ?? true ? nil : " "
    }
    
    var title: String {
        switch type {
        case .income:
            return sourceTitle
        case .expense, .fundsMove:
            return destinationTitle
        }
    }
    
    var subtitle: String {
        switch type {
        case .income:
            return destinationTitle
        case .expense, .fundsMove:
            return sourceTitle
        }
    }
    
    var iconURL: URL? {
        switch type {
        case .income:
            return sourceIconURL
        case .expense, .fundsMove:
            return destinationIconURL
        }
    }
    
    var iconPlaceholder: String {
        switch type {
        case .income:
            return sourceType.defaultIconName(basketType: basketType)
        case .expense, .fundsMove:
            return destinationType.defaultIconName(basketType: basketType)
        }
    }
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
}
