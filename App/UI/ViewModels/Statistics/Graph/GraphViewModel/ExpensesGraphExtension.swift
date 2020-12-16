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
    func calculateExpensesFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.expenseKey(for: $0) },
                                     transactionableIdForTransaction: { self.transactionableId(for: $0) },
                                     transactionableTypeForTransaction: { self.transactionableType(for: $0) },
                                     isVirtualTransactionable: { self.isVirtualTransactionable(for: $0) },
                                     isBorrowOrReturnTransactionable: { self.isBorrowOrReturnTransactionable(for: $0) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(for: $0) },
                                     iconURLForTransaction: { self.iconURL(for: $0) },
                                     iconPlaceholderForTransaction: { self.iconPlaceholder(for: $0) },
                                     colorForTransaction: { self.expenseColor(for: $0) })
    }
    
    private func expenseKey(for transaction: TransactionViewModel) -> String {
        return "\(transactionableType(for: transaction))_\(transactionableId(for: transaction))"
    }
    
    private func title(for transaction: TransactionViewModel) -> String {
        if transaction.destinationType == .expenseSource {
            return transaction.sourceTitle
        }
        return transaction.destinationTitle
    }
    
    private func isVirtualTransactionable(for transaction: TransactionViewModel) -> Bool {
        return transaction.destinationType == .expenseSource ? transaction.isVirtualSource : transaction.isVirtualDestination
    }

    private func isBorrowOrReturnTransactionable(for transaction: TransactionViewModel) -> Bool {
        return transaction.destinationType == .expenseSource ? transaction.isBorrowOrReturnSource : transaction.isBorrowOrReturnDestination
    }

    private func iconURL(for transaction: TransactionViewModel) -> URL? {
        if transaction.destinationType == .expenseSource {
            return transaction.sourceIconURL
        }
        return transaction.destinationIconURL
    }
    
    private func iconPlaceholder(for transaction: TransactionViewModel) -> String {
        return transactionableType(for: transaction).defaultIconName(basketType: transaction.basketType)
    }
    
    private func transactionableId(for transaction: TransactionViewModel) -> Int {
        if transaction.destinationType == .expenseSource {
            return transaction.sourceId
        }
        return transaction.destinationId
    }
    
    private func transactionableType(for transaction: TransactionViewModel) -> TransactionableType {
        if transaction.destinationType == .expenseSource {
            return transaction.sourceType
        }
        return transaction.destinationType
    }
    
    private func expenseColor(for transaction: TransactionViewModel) -> UIColor? {
        if transaction.destinationType == .expenseCategory {
            guard let idIndex = expenseCategoryIds.firstIndex(of: transaction.destinationId) else { return nil }
            return colors[safe: idIndex]
        }
        if transaction.destinationType == .active {
            guard let idIndex = activeIds.firstIndex(of: transaction.destinationId) else { return nil }            
            return colors[safe: idIndex + expenseCategoryIds.count]
        }
        if transaction.sourceType == .active {
            guard let idIndex = activeIds.firstIndex(of: transaction.sourceId) else { return nil }
            return colors[safe: idIndex + expenseCategoryIds.count]
        }
        return nil
    }
}
