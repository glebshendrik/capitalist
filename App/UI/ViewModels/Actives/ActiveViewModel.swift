//
//  ActiveViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class ActiveViewModel : TransactionSource, TransactionDestination {
    let active: Active
    
    var isSelected: Bool = false
    
    var isTransactionSource: Bool {
        return true
    }
    
    var id: Int {
        return active.id
    }
    
    var type: TransactionableType {
        return .active
    }
    
    var basketType: BasketType {
        return active.basketType
    }
    
    var activeType: ActiveType {
        return active.activeType
    }
    
    var activeTypeName: String {
        return activeType.localizedName
    }
    
    var name: String {
        return active.name
    }
    
    var prototypeKey: String? {
        return active.prototypeKey
    }
    
    var iconURL: URL? {
        return active.iconURL
    }
    
    var iconCategory: IconCategory? {
        return basketType.iconCategory
    }
        
    var defaultIconName: String {
        return type.defaultIconName(basketType: basketType)
    }
        
    var currency: Currency {
        return active.currency
    }
    
    var amountRounded: String {
        return cost(shouldRound: true)
    }
    
    var amount: String {
        return cost(shouldRound: false)
    }
    
    var costCents: Int {
        return active.costCents
    }
    
    var amountCents: Int {
        return costCents
    }
    
    var costRounded: String {
        return amountRounded
    }
    
    var cost: String {
        return amount
    }
    
    var goalAmountRounded: String {
        return goal(shouldRound: true)
    }
    
    var goalAmount: String {
        return goal(shouldRound: false)
    }
    
    var investedRounded: String {
        return invested(shouldRound: true)
    }
    
    var invested: String {
        return invested(shouldRound: true)
    }
    
    var spentRounded: String {
        return spent(shouldRound: true)
    }
    
    var spent: String {
        return spent(shouldRound: true)
    }
    
    var boughtRounded: String {
        return bought(shouldRound: true)
    }
    
    var bought: String {
        return bought(shouldRound: true)
    }
    
    var planned: String {
        return money(cents: active.monthlyPaymentCents, shouldRound: false)
    }
    
    var plannedAtPeriod: String? {
        return money(cents: active.paymentCentsAtPeriod, shouldRound: false)
    }
    
    var areExpensesPlanned: Bool {
        guard let monthlyPaymentCents = active.monthlyPaymentCents else { return false }
        return monthlyPaymentCents > 0
    }
    
    var isMonthlyPaymentPlanCompleted: Bool {
        return spendingProgress == 1.0
    }
    
    var spendingProgress: Double {
        guard   areExpensesPlanned,
                let monthlyPaymentCents = active.monthlyPaymentCents else { return 0 }
        let progress = Double(active.investedCents) / Double(monthlyPaymentCents)
        return progress > 1.0 ? 1.0 : progress
    }
        
    var isDeleted: Bool {
        return active.deletedAt != nil
    }
    
    var isGoal: Bool {
        return activeType.isGoalAmountRequired
    }
    
    var isVirtual: Bool {
        return false
    }
    
    var onlyBuyingAssets: Bool {
        return activeType.onlyBuyingAssets
    }
    
    var goalProgress: Double {
        guard isGoal, let goalAmountCents = active.goalAmountCents else { return 0 }
        let progress = Double(active.costCents) / Double(goalAmountCents)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isGoalCompleted: Bool {
        return goalProgress == 1.0
    }
    
    var annualPercent: String? {
        guard let percent = active.annualIncomePercent?.percentDecimalString() else { return nil }
        return "\(percent) %"
    }
    
    var monthlyPlannedIncome: String? {
        return active.monthlyPlannedIncomeCents?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var incomeSourceId: Int? {
        return active.incomeSource?.id
    }
    
    var iconType: IconType {
        return .raster
    }
    
    var fullSaleProfitCents: Int {
        return active.fullSaleProfitCents ?? 0
    }
    
    var fullSaleProfit: String {
        let profit = money(cents: fullSaleProfitCents, shouldRound: true)
        return "\(profitSign)\(profit)"
    }
    
    var profitSign: String {
        if hasPositiveProfit {
            return "+"
        }
        if hasNegativeProfit {
            return ""
        }
        return ""
    }
            
    var hasPositiveProfit: Bool {
        return fullSaleProfitCents > 0
    }
    
    var hasNegativeProfit: Bool {
        return fullSaleProfitCents < 0
    }
    
    var fullSaleProfitColorAsset: ColorAsset {
        if hasPositiveProfit {
            return .brandSafe
        }
        if hasNegativeProfit {
            return .red1
        }
        return .white100
    }
    
    var investmentsInCostCents: Int {
        let investmentsInCostCents = costCents - fullSaleProfitCents
        return investmentsInCostCents < 0 ? 0 : investmentsInCostCents
    }
    
    var investmentsInCost: String {
        return money(cents: investmentsInCostCents, shouldRound: true)
    }
    
    init(active: Active) {
        self.active = active
    }
    
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool {
        
        if transactionSource is ExpenseSourceViewModel {            
            return true
        }
        
        if let sourceIncomeSourceViewModel = transactionSource as? IncomeSourceViewModel {
            return sourceIncomeSourceViewModel.incomeSource.activeId == self.id
        }
        
        return false
    }
    
    private func cost(shouldRound: Bool) -> String {
        return money(cents: active.costCents, shouldRound: shouldRound)
    }
    
    private func goal(shouldRound: Bool) -> String {
        return money(cents: active.goalAmountCents, shouldRound: shouldRound)
    }
    
    private func invested(shouldRound: Bool) -> String {
        return money(cents: active.investedCents, shouldRound: shouldRound)
    }
    
    private func bought(shouldRound: Bool) -> String {
        return money(cents: active.boughtCents, shouldRound: shouldRound)
    }
    
    private func spent(shouldRound: Bool) -> String {
        return money(cents: active.spentCents, shouldRound: shouldRound)
    }
    
    private func money(cents: Int?, shouldRound: Bool) -> String {
        return cents?.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
