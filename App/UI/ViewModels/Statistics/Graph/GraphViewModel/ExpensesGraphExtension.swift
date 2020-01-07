//
//  ExpensesGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    func calculateExpensesPieChartData() -> PieChartData? {
        return calculatePieChartData(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.expenseKey(for: $0) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { $0.destinationTitle },
                                     colorForTransaction: { self.expenseColor(for: $0) })
    }
        
    func calculateExpensesFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.expenseKey(for: $0) },
                                     transactionableIdForTransaction: { $0.destinationId },
                                     transactionableTypeForTransaction: { $0.destinationType },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { $0.destinationTitle },
                                     iconURLForTransaction: { $0.destinationIconURL },
                                     iconPlaceholderForTransaction: { $0.destinationType.defaultIconName(basketType: $0.basketType) },
                                     colorForTransaction: { self.expenseColor(for: $0) })
    }
    
    private func expenseKey(for transaction: TransactionViewModel) -> String {
        return "\(transaction.destinationType)_\(transaction.destinationId)"
    }
    
    private func expenseColor(for transaction: TransactionViewModel) -> UIColor? {
        if transaction.destinationType == .expenseCategory {
            guard let idIndex = expenseCategoryIds.firstIndex(of: transaction.destinationId) else { return nil }
            return colors.item(at: idIndex)
        }
        if transaction.destinationType == .active {
            guard let idIndex = activeIds.firstIndex(of: transaction.destinationId) else { return nil }
            return colors.item(at: idIndex + expenseCategoryIds.count)
        }
        return nil
    }
}
