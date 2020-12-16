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
    func calculateIncomeAndExpensesFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0) },
                                     transactionableIdForTransaction: { self.id(by: $0) },
                                     transactionableTypeForTransaction: { _ in .incomeSource },
                                     isVirtualTransactionable: { _ in false },
                                     isBorrowOrReturnTransactionable: { _ in false },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(by: $0) },
                                     iconURLForTransaction: { _ in nil },
                                     iconPlaceholderForTransaction: { self.imagePlaceholder(by: $0) },
                                     colorForTransaction: { self.incomeAndExpensesColor(by: $0) },
                                     coloringType: .progress,
                                     sortingType: .id)
    }
    
    func type(by transaction: TransactionViewModel) -> TransactionType {
        if transaction.type == .fundsMove && transaction.hasNonZeroProfit {
            return transaction.hasPositiveProfit ? .income : .expense
        }
        return transaction.type
    }
    
    func type(by incomeAndExpensesKey: String) -> TransactionType {
        return TransactionType(rawValue: incomeAndExpensesKey) ?? TransactionType.fundsMove
    }
    
    func incomeAndExpensesDataSetKey(by transaction: TransactionViewModel) -> String {
        return type(by: transaction).rawValue
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
    
    private func title(by transaction: TransactionViewModel) -> String {
        switch type(by: transaction) {
        case .income:       return NSLocalizedString("Доход", comment: "Доход")
        case .expense:      return NSLocalizedString("Расходы", comment: "Расходы")
        case .fundsMove:    return NSLocalizedString("Переводы", comment: "Переводы")
        }
    }
    
    private func id(by transaction: TransactionViewModel) -> Int {
        switch type(by: transaction) {
        case .income:       return 0
        case .expense:      return 1
        case .fundsMove:    return 2
        }
    }
    
    private func imagePlaceholder(by transaction: TransactionViewModel) -> String? {
        switch type(by: transaction) {
        case .income:       return "incomes-icon"
        case .expense:      return "expenses-icon"
        default:            return nil
        }
    }
    
    private func incomeAndExpensesColor(by transaction: TransactionViewModel) -> UIColor {
        switch type(by: transaction) {
        case .income:       return UIColor.by(.blue1)
        case .expense:      return UIColor.by(.white4)
        case .fundsMove:    return .blue
        }
    }
}
