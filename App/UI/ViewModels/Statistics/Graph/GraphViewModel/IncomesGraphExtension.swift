//
//  IncomeGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift

extension GraphViewModel {
    func calculateIncomeFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeKey(for: $0) },
                                     transactionableIdForTransaction: { self.transactionableId(for: $0) },
                                     transactionableTypeForTransaction: { self.transactionableType(for: $0) },
                                     isVirtualTransactionable: { self.isVirtualTransactionable(for: $0) },
                                     isBorrowOrReturnTransactionable: { self.isBorrowOrReturnTransactionable(for: $0) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(for: $0) },
                                     iconURLForTransaction: { self.iconURL(for: $0) },
                                     iconPlaceholderForTransaction: { self.iconPlaceholder(for: $0) },
                                     colorForTransaction: { self.incomeColor(for: $0) })
    }
    
    private func incomeKey(for transaction: TransactionViewModel) -> String {
        return "\(transactionableType(for: transaction))_\(transactionableId(for: transaction))"
    }
    
    private func title(for transaction: TransactionViewModel) -> String {
        if let sourceActiveTitle = transaction.sourceActiveTitle {
            return sourceActiveTitle
        }
        if transaction.destinationType == .active {
            return transaction.destinationTitle
        }
        return transaction.sourceTitle
    }
    
    private func isVirtualTransactionable(for transaction: TransactionViewModel) -> Bool {
        return transaction.destinationType == .active ? transaction.isVirtualDestination : transaction.isVirtualSource
    }

    private func isBorrowOrReturnTransactionable(for transaction: TransactionViewModel) -> Bool {
        return transaction.destinationType == .active ? transaction.isBorrowOrReturnDestination : transaction.isBorrowOrReturnSource
    }
    
    private func iconURL(for transaction: TransactionViewModel) -> URL? {
        if let sourceActiveIconURL = transaction.sourceActiveIconURL {
            return sourceActiveIconURL
        }
        if transaction.destinationType == .active {
            return transaction.destinationIconURL
        }
        return transaction.sourceIconURL
    }
    
    private func iconPlaceholder(for transaction: TransactionViewModel) -> String {
        return transactionableType(for: transaction).defaultIconName(basketType: transaction.basketType)
    }
    
    private func transactionableId(for transaction: TransactionViewModel) -> Int {
        if let activeId = transaction.sourceActiveId {
            return activeId
        }
        if transaction.destinationType == .active {
            return transaction.destinationId
        }
        return transaction.sourceId
    }
    
    private func transactionableType(for transaction: TransactionViewModel) -> TransactionableType {
        if transaction.isAssetSource {
            return .active
        }
        if transaction.destinationType == .active {
            return transaction.destinationType
        }
        return transaction.sourceType
    }
    
    private func incomeColor(for transaction: TransactionViewModel) -> UIColor? {
        if transaction.destinationType == .active {
            guard let idIndex = activeIds.firstIndex(of: transaction.destinationId) else { return nil }
            return colors[safe: idIndex + incomeSourceIds.count]
        }
        if transaction.destinationType == .expenseSource {
            guard let idIndex = incomeSourceIds.firstIndex(of: transaction.sourceId) else { return nil }
            return colors[safe: idIndex]
        }
        return nil
    }
}
