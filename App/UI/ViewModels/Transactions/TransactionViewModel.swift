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
    
    var isActiveCreation: Bool {
        return transaction.active != nil
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
        
    var amountSign: String {
        if type == .income || isAssetCostIncrement {
            return "+"
        }
        if type == .expense || isAssetCostDecrement {
            return "-"
        }
        return ""
    }
    
    var amount: String {
        guard let transactionAmount = calculatingAmountCents.moneyCurrencyString(with: calculatingCurrency, shouldRound: false) else { return "" }
        return "\(amountSign)\(transactionAmount)"
    }
    
    var isAssetCostIncrement: Bool {
        return type == .fundsMove && sourceType == .expenseSource && destinationType == .active && isVirtualSource
    }
    
    var isAssetCostDecrement: Bool {
        return type == .fundsMove && sourceType == .active && destinationType == .expenseSource && isVirtualDestination
    }
    
    var profitCents: Int? {
        return transaction.profitCents
    }
    
    var profitSign: String {
        if hasPositiveProfit {
            return "+"
        }
        if hasNegativeProfit {
            return "-"
        }
        return ""
    }
    
    var hasPositiveProfit: Bool {
        guard let profitCents = profitCents else { return false }
        return profitCents > 0
    }
    
    var hasNegativeProfit: Bool {
        guard let profitCents = profitCents else { return false }
        return profitCents < 0
    }
    
    var profit: String? {
        guard let profit = profitCents?.moneyCurrencyString(with: calculatingCurrency, shouldRound: false) else { return nil }
        return "\(profitSign)\(profit)"
    }
    
    var hasProfit: Bool {
        return profitCents != nil
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
        if hasNegativeProfit || hasPositiveProfit {
            return profit
        }
        
        return comment?.isEmpty ?? true ? nil : " "
    }
    
    var typeDescriptionColorAsset: ColorAsset {
        if hasNegativeProfit {
            return .red1
        }
        if hasPositiveProfit {
            return .brandSafe
        }
        return .white64
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
    
    var isAssetSource: Bool {
        return transaction.isAssetSource
    }
    
    var sourceActiveId: Int? {
        return transaction.sourceActiveId
    }
    
    var sourceActiveTitle: String? {
        return transaction.sourceActiveTitle
    }
    
    var sourceActiveIconURL: URL? {
        return transaction.sourceActiveIconURL
    }
    
    var titleTransactionPart: TransactionPart {
        switch (type, sourceType, destinationType) {
        case (.income, .incomeSource, _):
            return isVirtualSource ? .destination : .source
        case (.expense, .expenseSource, _):
            return isVirtualDestination ? .source : .destination
        case (.fundsMove, .expenseSource, .expenseSource):
            if isVirtualDestination {
                return .source
            }
            if isVirtualSource {
                return .destination
            }
            return .source
        case (.fundsMove, .expenseSource, .active):
            return .destination
        case (.fundsMove, .active, .expenseSource):
            return .source
        default:
            return .source
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
        let assetPurchaseWord = NSLocalizedString("Покупка актива", comment: "Покупка актива")
        let assetExpenseWord = NSLocalizedString("Расход по активу", comment: "")
        let assetSaleWord = NSLocalizedString("Продажа актива", comment: "")

        if isCrediting {
            return isVirtual ? creditWord : "\(creditWord) · \(subtitle)"
        }
        if isLoan {
            return isVirtual ? loanWord : "\(loanWord) · \(subtitle)"
        }
        if isDebt {
            return isVirtual ? debtWord : "\(debtWord) · \(subtitle)"
        }
        if isActiveCreation {
            return isVirtual ? assetPurchaseWord : "\(assetPurchaseWord) · \(subtitle)"
        }
        if isVirtual {
            if sourceType == .active || destinationType == .active {
                return NSLocalizedString("Переоценка актива", comment: "Переоценка актива")
            }
            if sourceType == .expenseSource && destinationType == .expenseSource {
                return NSLocalizedString("Создание кошелька", comment: "Создание кошелька")
            }
            return NSLocalizedString("Изменено Вами", comment: "Изменено Вами")
        }
        if type == .expense && destinationType == .active {
            return "\(assetExpenseWord) · \(subtitle)"
        }
        if type == .fundsMove && destinationType == .active {
            return "\(assetPurchaseWord) · \(subtitle)"
        }
        if type == .fundsMove && sourceType == .active {
            return "\(assetSaleWord) · \(subtitle)"
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
