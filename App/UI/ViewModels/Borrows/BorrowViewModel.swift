//
//  BorrowViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class BorrowViewModel {
    public private(set) var borrow: Borrow
    
    var id: Int {
        return borrow.id
    }
    
    var type: BorrowType {
        return borrow.type
    }
    
    var name: String {
        return borrow.name
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var amountLeftRounded: String {
        return amountLeft(shouldRound: true)
    }
    
    var amountLeft: String {
        return amountLeft(shouldRound: false)
    }
    
    var amountLeftDecimal: String {
        return borrow.amountCentsLeft.moneyDecimalString(with: currency) ?? ""
    }
    
    var amountReturnedRounded: String {
        return amountReturned(shouldRound: true)
    }
    
    var amountReturned: String {
        return amountReturned(shouldRound: false)
    }
    
    var diplayAmount: String {
        return amountLeftRounded
    }
    
    var currency: Currency {
        return borrow.currency
    }
    
    var iconURL: URL? {
        return borrow.iconURL
    }
    
    var isDebt: Bool {
        return type == .debt
    }
    
    var isLoan: Bool {
        return type == .loan
    }
    
    var isReturned: Bool {
        return borrow.isReturned
    }
        
    var defaultIconName: String {
        return IconCategory.expenseSourceDebt.defaultIconName
    }
    
    var borrowedAt: Date {
        return borrow.borrowedAt
    }
    
    var borrowedAtFormatted: String {
        return borrowedAt.dateString(ofStyle: .short)
    }
    
    var comment: String? {
        return borrow.comment
    }
    
    var paydayFormatted: String? {
        return borrow.payday?.dateString(ofStyle: .short)
    }
    
    var paydayText: String? {
        guard let paydayFormatted = paydayFormatted else { return nil }
        return "До \(paydayFormatted)"
    }
    
    var borrowingTransactionId: Int? {
        return borrow.borrowingTransactionId
    }
    
    var title: String {
        switch type {
        case .debt: return "Долг (вам должны)"
        case .loan: return "Займ (вы должны)"
        }
    }
    
    init(borrow: Borrow) {
        self.borrow = borrow
    }
    
    private func amount(shouldRound: Bool) -> String {
        return borrow.amountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func amountLeft(shouldRound: Bool) -> String {
        return borrow.amountCentsLeft.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func amountReturned(shouldRound: Bool) -> String {
        return borrow.returnedAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
