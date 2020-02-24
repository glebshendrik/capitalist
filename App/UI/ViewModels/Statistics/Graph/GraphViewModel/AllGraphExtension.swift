//
//  IncomeAndExpensesGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    func calculateIncomeAndExpensesPieChartData() -> PieChartData? {
        return calculatePieChartData(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.type) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(by: $0.type) },
                                     colorForTransaction: { self.incomeAndExpensesColor(by: $0.type) })
    }
    
    func calculateIncomeAndExpensesFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.type) },
                                     transactionableIdForTransaction: { self.id(by: $0.type) },
                                     transactionableTypeForTransaction: { _ in .incomeSource },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(by: $0.type) },
                                     iconURLForTransaction: { _ in nil },
                                     iconPlaceholderForTransaction: { self.imagePlaceholder(by: $0.type) },
                                     colorForTransaction: { self.incomeAndExpensesColor(by: $0.type) },
                                     coloringType: .progress,
                                     sortingType: .id)
    }
    
    func type(by incomeAndExpensesKey: String) -> TransactionType {
        return TransactionType(rawValue: incomeAndExpensesKey) ?? TransactionType.fundsMove
    }
    
    func incomeAndExpensesDataSetKey(by type: TransactionType) -> String {
        return type.rawValue
    }
    
    func typeBy(incomeAndExpensesId: Int) -> TransactionType? {
        switch incomeAndExpensesId {
        case 0:
            return .income
        case 1:
            return .expense
        default:
            return nil
        }
    }
    
    private func title(by type: TransactionType) -> String {
        switch type {
        case .income:       return NSLocalizedString("Доход", comment: "Доход")
        case .expense:      return NSLocalizedString("Расходы", comment: "Расходы")
        case .fundsMove:    return NSLocalizedString("Переводы", comment: "Переводы")
        }
    }
    
    private func id(by type: TransactionType) -> Int {
        switch type {
        case .income:       return 0
        case .expense:      return 1
        case .fundsMove:    return 2
        }
    }
    
    private func imagePlaceholder(by type: TransactionType) -> String? {
        switch type {
        case .income:       return "incomes-icon"
        case .expense:      return "expenses-icon"
        default:            return nil
        }
    }
    
    private func incomeAndExpensesColor(by type: TransactionType) -> UIColor {
        switch type {
        case .income:       return UIColor.by(.blue1)
        case .expense:      return UIColor.by(.white4)
        case .fundsMove:    return .blue
        }
    }
}
