//
//  FundsMoveViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
        return convertedCurrency
    }
    
    var calculatingAmountCents: Int {
        return convertedAmountCents
    }
    
    var gotAt: Date {
        return fundsMove.gotAt
    }
    
    var amount: String {
        return calculatingAmountCents.moneyCurrencyString(with: calculatingCurrency, shouldRound: false) ?? ""
    }
    
    var comment: String? {
        return fundsMove.comment
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
    
    init(fundsMove: FundsMove) {
        self.fundsMove = fundsMove
        expenseSourceFrom = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceFrom)
        expenseSourceTo = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceTo)
    }
}
