//
//  FundsMoveViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class FundsMoveViewModel {
    let fundsMove: FundsMove
    let expenseSourceFrom: ExpenseSourceViewModel
    let expenseSourceTo: ExpenseSourceViewModel
    
    var id: Int {
        return fundsMove.id
    }
    
    var sourceTitle: String {
        return expenseSourceFrom.name
    }
    
    var destinationTitle: String {
        return expenseSourceTo.name
    }
    
    var amount: String {
        return amountCents.moneyCurrencyString(with: currency, shouldRound: false) ?? ""
    }
    
    var convertedAmount: String {
        return convertedAmountCents.moneyCurrencyString(with: convertedCurrency, shouldRound: false) ?? ""
    }
    
    var debtAmount: String {
        return isDebt ? convertedAmount : amount
    }
    
    var gotAt: Date {
        return fundsMove.gotAt
    }
    
    var gotAtFormatted: String {
        return gotAt.dateString(ofStyle: .short)
    }
    
    var comment: String? {
        return fundsMove.comment
    }
    
    var borrowedTillFormatted: String? {
        return fundsMove.borrowedTill?.dateString(ofStyle: .short)
    }
    
    var borrowedTillLabelTitle: String? {
        guard let borrowedTillFormatted = borrowedTillFormatted else { return nil }
        return "До \(borrowedTillFormatted)"
    }
    
    var whom: String? {
        return fundsMove.whom
    }
    
    var whomLabelTitle: String? {
        if let whom = whom {
            return whom
        }
        if isDebt {
            return "Вы одолжили"
        }
        if isLoan {
            return "Вы заняли"
        }
        return nil
    }
    
    var isDebt: Bool {
        return !isReturn && expenseSourceTo.isDebt
    }
    
    var isLoan: Bool {
        return !isReturn && expenseSourceFrom.isDebt
    }
    
    var isReturn: Bool {
        return fundsMove.debtTransaction != nil
    }
    
    var currency: Currency {
        return fundsMove.currency
    }
    
    var amountCents: Int {
        return fundsMove.amountCents
    }
    
    var convertedCurrency: Currency {
        return fundsMove.convertedCurrency
    }
    
    var convertedAmountCents: Int {
        return fundsMove.convertedAmountCents
    }
    
    var calculatingCurrency: Currency {
        return fundsMove.convertedCurrency
    }
    
    var calculatingAmountCents: Int {
        return fundsMove.convertedAmountCents
    }
    
    init(fundsMove: FundsMove) {
        self.fundsMove = fundsMove
        expenseSourceFrom = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceFrom)
        expenseSourceTo = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceTo)
    }
}
