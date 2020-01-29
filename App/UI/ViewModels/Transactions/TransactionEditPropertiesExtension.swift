//
//  TransactionEditComputablesExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

extension TransactionEditViewModel {
    var isNew: Bool {
        return transactionId == nil
    }
    
    var sourceId: Int? {
        return source?.id
    }
    
    var sourceType: TransactionableType? {
        return source?.type
    }
    
    var destinationId: Int? {
        return destination?.id
    }
    
    var destinationType: TransactionableType? {
        return destination?.type
    }
    
    var transactionType: TransactionType? {
        return TransactionType.typeFor(sourceType: sourceType, destinationType: destinationType)
    }
    
    var amountToSave: String? {
        if let amount = amount, !amount.isEmpty {
            return amount
        }
        return amountConverted
    }
    
    var convertedAmountToSave: String? {
        if let convertedAmount = convertedAmount, !convertedAmount.isEmpty {
            return convertedAmount
        }
        return convertedAmountConverted
    }
    
    var amountPlaceholder: String? {
        return amountConverted ?? sourceAmountTitle
    }
    
    var convertedAmountPlaceholder: String? {
        return convertedAmountConverted ?? destinationAmountTitle
    }
    
    var calendarTitle: String {
        guard let gotAt = gotAt else { return "Выбрать дату" }
        return gotAt.dateTimeString(ofStyle: .short)
    }
    
    var buyingAssetsTitle: String? {
        return (destination as? ActiveViewModel)?.activeType.buyingAssetsTitle
    }
}

extension TransactionEditViewModel {
    var userId: Int? {
        return accountCoordinator.currentSession?.userId
    }
    
    var amountCents: Int? {
        return amountToSave?.intMoney(with: sourceCurrency)        
    }
    
    var convertedAmountCents: Int? {
        return convertedAmountToSave?.intMoney(with: destinationCurrency)
    }
    
    var amountCurrency: String? {
        return sourceCurrencyCode
    }
    
    var convertedAmountCurrency: String? {
        return destinationCurrencyCode
    }
}

extension TransactionEditViewModel {
    var isValid: Bool {
        return isNew
            ? isCreationFormValid()
            : isUpdatingFormValid()
    }
    
    var hasComment: Bool {
        guard let comment = comment else { return false }
        return !comment.isEmpty && !comment.isWhitespace
    }
    
    var hasGotAtDate: Bool {
        return gotAt != nil
    }
    
    var canSave: Bool {
        return hasBothTransactionables        
    }
    
    var hasBothTransactionables: Bool {
        return source != nil && destination != nil
    }
    
    var needCurrencyExchange: Bool {
        return sourceCurrencyCode != destinationCurrencyCode
    }
    
    var amountFieldHidden: Bool {
        return needCurrencyExchange || !hasBothTransactionables
    }
    
    var exchangeAmountsFieldHidden: Bool {
        return !needCurrencyExchange || !hasBothTransactionables
    }
    
    var isBuyingAssetFieldHidden: Bool {
        guard   isNew,
                let transactionType = transactionType,
                let destination = destination else { return true }
        
        var onlyBuyingAssets = false
        if let destination = destination as? ActiveViewModel {
            onlyBuyingAssets = destination.activeType.onlyBuyingAssets
        }
        
        return transactionType != .expense || destination.type != .active || onlyBuyingAssets
    }
    
    var removeButtonHidden: Bool {
        return isNew        
    }
    
    var canChangeSource: Bool {
        return !isReturningDebt && !anyVirtualTransactionable
    }
    
    var canChangeDestination: Bool {
        return !isReturningLoan && !anyVirtualTransactionable
    }
    
    var anyVirtualTransactionable: Bool {
        return isSourceVirtualExpenseSource || isDestinationVirtualExpenseSource
    }
    
    var isSourceVirtualExpenseSource: Bool {
        guard let expenseSourceSource = source as? ExpenseSourceViewModel else { return false }
        return expenseSourceSource.isVirtual
    }
    
    var isDestinationVirtualExpenseSource: Bool {
        guard let expenseSourceSource = destination as? ExpenseSourceViewModel else { return false }
        return expenseSourceSource.isVirtual
    }
}

extension TransactionEditViewModel {
    var title: String {
        if let transactionType = transactionType {
            return transactionType.title(isNew: isNew, isReturn: isReturn)
        }
        switch (isNew, isReturn) {
        case   (true,  false):  return "Новый перевод"
        case   (true,  true):   return "Новый возврат"
        case   (false, false):  return "Изменить перевод"
        case   (false,  true):   return "Изменить возврат"
        }
    }
        
    var removeTitle: String? {
        guard !isNew else { return nil }
        return transactionType?.removeTitle(isReturn: isReturn) ?? "Удалить"
    }
    
    var removeQuestion: String? {
        guard !isNew else { return nil }
        return transactionType?.removeQuestion(isReturn: isReturn) ?? "Удалить?"
    }
    
    var sourceTitle: String? {
        return sourceType?.title(as: .source) ?? "Выберите источник"
    }
    var sourceAmountTitle: String? { return "Сумма" }
    var sourceIconURL: URL? { return source?.iconURL }
    var sourceIconDefaultImageName: String {
        return source?.defaultIconName ?? sourceType?.defaultIconName ?? "lamp-icon"
    }
    var sourceName: String? { return isSourceVirtualExpenseSource ? "Из ниоткуда" : source?.name }
    var sourceAmount: String? { return isSourceVirtualExpenseSource ? nil : source?.amountRounded }
    var sourceCurrency: Currency? { return source?.currency }
    var sourceCurrencyCode: String? { return sourceCurrency?.code }
    
    var destinationTitle: String? {
        return destinationType?.title(as: .destination) ?? "Выберите назначение"
        
    }
    var destinationAmountTitle: String? { return "Сумма" }
    var destinationIconURL: URL? { return destination?.iconURL }
    var destinationIconDefaultImageName: String {
        return destination?.defaultIconName ?? destinationType?.defaultIconName ?? "lamp-icon"        
    }
    var destinationName: String? { return isDestinationVirtualExpenseSource ? "В никуда" : destination?.name }
    var destinationAmount: String? { return isDestinationVirtualExpenseSource ? nil : destination?.amountRounded }
    var destinationCurrency: Currency? { return destination?.currency }
    var destinationCurrencyCode: String? { return destinationCurrency?.code }
}

extension TransactionableType {
    var removeQuestion: String {
        switch (self) {
        case .incomeSource:                 return "Удалить источник дохода?"
        case .expenseSource:                return "Удалить кошелек?"
        case .expenseCategory:              return "Удалить категорию трат?"
        case .active:                       return "Удалить актив?"
        }
    }
    
    func title(as part: TransactionPart) -> String {
        switch (self, part) {
        case (.incomeSource, _):                return "Источник дохода"
        case (.expenseSource, .source):         return "Кошелек"
        case (.expenseSource, .destination):    return "Кошелек"
        case (.expenseCategory, _):             return "Категория трат"
        case (.active, _):                      return "Актив"
        }
    }
}

extension TransactionType {
    static func typeFor(sourceType: TransactionableType?, destinationType: TransactionableType?) -> TransactionType? {
        
        guard let sourceType = sourceType, let destinationType = destinationType else { return nil }
        
        switch (sourceType, destinationType) {
        case (.incomeSource, .expenseSource),
             (.incomeSource, .active),
             (.active, .expenseSource):             return .income
        case (.expenseSource, .expenseSource):      return .fundsMove
        case (.expenseSource, .expenseCategory),
             (.expenseSource, .active):             return .expense
        default:                                    return nil
        }
    }
    
    func title(isNew: Bool, isReturn: Bool) -> String {
        switch (isNew, isReturn, self) {
        case   (true,  true, _):                return "Новый возврат"
        case   (false,  true, _):               return "Изменить возврат"
        case   (true,  false, .income):         return "Новый доход"
        case   (true,  false, .fundsMove):      return "Новый перевод"
        case   (true,  false, .expense):        return "Новый расход"
        case   (false, false, .income):         return "Изменить доход"
        case   (false, false, .fundsMove):      return "Изменить перевод"
        case   (false, false, .expense):        return "Изменить расход"
        }
    }
    
    func removeTitle(isReturn: Bool) -> String {
        switch (isReturn, self) {
        case   (true, _):               return "Удалить возврат"
        case   (false, .income):        return "Удалить доход"
        case   (false, .fundsMove):     return "Удалить перевод"
        case   (false, .expense):       return "Удалить расход"
        }
    }
    
    func removeQuestion(isReturn: Bool) -> String {
        return "\(removeTitle(isReturn: isReturn))?"
    }
}
