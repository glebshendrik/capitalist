//
//  CreditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class CreditViewModel {
    public private(set) var credit: Credit
    public private(set) var reminderViewModel: ReminderViewModel
    public private(set) var creditTypeViewModel: CreditTypeViewModel
    
    var id: Int {
        return credit.id
    }
    
    var iconURL: URL? {
        return credit.iconURL
    }
        
    var name: String {
        return credit.name
    }
    
    var type: CreditType {
        return credit.creditType
    }
    
    var typeName: String {
        return type.localizedName
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var returnAmount: String {
        return returnAmount(shouldRound: false)
    }
    
    var returnAmountRounded: String {
        return returnAmount(shouldRound: true)
    }
    
    var paidAmount: String {
        return paidAmount(shouldRound: false)
    }
    
    var paidAmountRounded: String {
        return paidAmount(shouldRound: true)
    }
    
    var amountLeft: String {
        return amountLeft(shouldRound: false)
    }
    
    var amountLeftRounded: String {
        return amountLeft(shouldRound: true)
    }
    
    var areExpensesPlanned: Bool {
        guard let monthlyPaymentCents = credit.monthlyPaymentCents else { return false }
        return monthlyPaymentCents > 0
    }
    
    var monthlyPayment: String {
        return monthlyPayment(shouldRound: false)
    }
    
    var nextPaymentDate: String? {
        return reminderViewModel.nextOccurrence
    }
    
    var paymentsProgress: Float {
        let ratio = Float(credit.paidAmountCents) / Float(credit.returnAmountCents)
        return ratio > 1.0 ? 1.0 : ratio
    }
    
    var currency: Currency {
        return credit.currency
    }
    
    var gotAtFormatted: String {
        return credit.gotAt.dateString(ofStyle: .short)
    }
    
    var periodFormatted: String {
        return creditTypeViewModel.formatted(value: Int(credit.period))
    }
    
    var isPaid: Bool {
        return credit.isPaid
    }
    
    init(credit: Credit) {
        self.credit = credit
        self.reminderViewModel = ReminderViewModel(reminder: credit.reminder)
        self.creditTypeViewModel = CreditTypeViewModel(creditType: credit.creditType)
    }
    
    private func monthlyPayment(shouldRound: Bool) -> String {
        return credit.monthlyPaymentCents?.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func amount(shouldRound: Bool) -> String {
        return credit.amountCents?.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func returnAmount(shouldRound: Bool) -> String {
        return credit.returnAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func paidAmount(shouldRound: Bool) -> String {
        return credit.paidAmountCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
    
    private func amountLeft(shouldRound: Bool) -> String {
        return credit.amountLeftCents.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
