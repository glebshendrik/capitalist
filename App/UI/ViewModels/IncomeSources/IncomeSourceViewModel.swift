//
//  IncomeSourceViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

class IncomeSourceViewModel : TransactionSource {
    
    var isSelected: Bool = false
    
    var type: TransactionableType {
        return .incomeSource
    }
    
    var iconCategory: IconCategory? {
        return nil
    }
    
    var isTransactionSource: Bool {
        return true
    }
    
    public private(set) var incomeSource: IncomeSource
    
    var id: Int {
        return incomeSource.id
    }
    
    var name: String {
        return incomeSource.name
    }
    
    var prototypeKey: String? {
        return incomeSource.prototypeKey
    }
    
    var amountRounded: String {
        return amount(shouldRound: true)
    }
    
    var amount: String {
        return amount(shouldRound: false)
    }
    
    var currency: Currency {
        return incomeSource.currency
    }
    
    var plannedAtPeriod: String? {
        return incomeSource.plannedCentsAtPeriod?.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var areIncomesPlanned: Bool {
        guard let plannedCentsAtPeriod = incomeSource.plannedCentsAtPeriod else { return false }
        return plannedCentsAtPeriod > 0
    }
    
    var incomeProgress: Double {
        guard   areIncomesPlanned,
                let plannedCentsAtPeriod = incomeSource.plannedCentsAtPeriod else { return 0 }
        let progress = Double(incomeSource.gotCentsAtPeriod) / Double(plannedCentsAtPeriod)
        return progress > 1.0 ? 1.0 : progress
    }
    
    var isIncomeProgressCompleted: Bool {
        return incomeProgress == 1.0
    }
    
    var iconURL: URL? {
        return incomeSource.iconURL
    }
    
    var isDeleted: Bool {
        return incomeSource.deletedAt != nil
    }
    
    var isChild: Bool {
        return incomeSource.isChild
    }
    
    var isBorrowOrReturn: Bool {
        return incomeSource.isBorrowOrReturn
    }
    
    public private(set) var waitingDebts: [BorrowViewModel] = []
    
    var hasWaitingDebts: Bool {
        return waitingDebts.count > 0
    }
    
    var activeId: Int? {
        return incomeSource.activeId
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
        waitingDebts = incomeSource.waitingDebts.map { BorrowViewModel(borrow: $0) }
    }
    
    func asTransactionFilter() -> IncomeSourceFilter {
        return IncomeSourceFilter(incomeSourceViewModel: self)
    }
    
    private func amount(shouldRound: Bool) -> String {
        return incomeSource.gotCentsAtPeriod.moneyCurrencyString(with: currency, shouldRound: shouldRound) ?? ""
    }
}
