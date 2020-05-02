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
        if isCrediting {
            return NSLocalizedString("Вы взяли кредит", comment: "")
        }
        if transaction.isAssetSource {
            return NSLocalizedString("Дивиденды", comment: "Дивиденды")
        }
        
        return comment?.isEmpty ?? true ? nil : " "
    }
    
    var isVirtualSource: Bool {
        return transaction.isVirtualSource
    }
    
    var isVirtualDestination: Bool {
        return transaction.isVirtualDestination
    }
    
    var isVirtual: Bool {
        return isVirtualSource || isVirtualDestination
    }
    
    var isBorrowOrReturnSource: Bool {
        return transaction.isBorrowOrReturnSource
    }
    
    var isBorrowOrReturnDestination: Bool {
        return transaction.isBorrowOrReturnDestination
    }
    
    var titleTransactionPart: TransactionPart {
        switch type {
        case .income:
            return sourceType == .incomeSource && !isVirtualSource ? .source : .destination
        case .expense:
            return destinationType == .expenseSource || (sourceType == .expenseSource && destinationType == .expenseCategory && isVirtualDestination) ? .source : .destination
        case .fundsMove:
            return .destination
        }
    }
    
    var title: String {
        let title = titleTransactionPart == .source ? sourceTitle : destinationTitle
        
        if let credit = transaction.credit {
            return credit.name
        }
        if let borrow = transaction.borrow {
            return borrow.name
        }
        if let returningBorrow = transaction.returningBorrow {
            return returningBorrow.name
        }
        
        return title
    }
    
    var subtitle: String {
        let subtitle = titleTransactionPart == .source ? destinationTitle : sourceTitle
        let creditWord = NSLocalizedString("Кредит", comment: "Кредит")
        let loanWord = NSLocalizedString("Займ", comment: "Займ")
        let debtWord = NSLocalizedString("Долг", comment: "Долг")

        if isCrediting {
            return isVirtual ? creditWord : "\(creditWord) · \(subtitle)"
        }
        if isLoan {
            return isVirtual ? loanWord : "\(loanWord) · \(subtitle)"
        }
        if isDebt {
            return isVirtual ? debtWord : "\(debtWord) · \(subtitle)"
        }
        if isVirtual {
            return sourceType == .active || destinationType == .active ? NSLocalizedString("Переоценка актива", comment: "Переоценка актива") : NSLocalizedString("Изменено Вами", comment: "Изменено Вами")
        }
        return subtitle
    }
    
    var iconURL: URL? {
        let iconURL = titleTransactionPart == .source ? sourceIconURL : destinationIconURL
        
        if let credit = transaction.credit {
            return credit.iconURL
        }
        if let borrow = transaction.borrow {
            return borrow.iconURL
        }
        if let returningBorrow = transaction.returningBorrow {
            return returningBorrow.iconURL
        }
        
        return iconURL
    }
    
    var transactionableType: TransactionableType {
        return titleTransactionPart == .source ? sourceType : destinationType
    }
    
    var iconPlaceholder: String {
        let iconPlaceholder = transactionableType.defaultIconName(basketType: basketType)
        
        if isCrediting {
            return "credit-default-icon"
        }
        if isBorrowing || isReturn {
            return "borrow-default-icon"
        }
        
        return iconPlaceholder
    }
    
    var iconType: IconType {
        return iconURL?.absoluteString.components(separatedBy: ".").last == "svg" ? .vector : .raster
    }
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
}
