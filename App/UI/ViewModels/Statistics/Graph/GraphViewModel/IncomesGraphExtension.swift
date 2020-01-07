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
    func calculateIncomePieChartData() -> PieChartData? {
        return calculatePieChartData(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeKey(for: $0) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { $0.sourceTitle },
                                     colorForTransaction: { self.incomeColor(for: $0) })
        
    }
        
    func calculateIncomeFilters() -> [GraphTransactionFilter] {
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     keyForTransaction: { self.incomeKey(for: $0) },
                                     transactionableIdForTransaction: { $0.sourceId },
                                     transactionableTypeForTransaction: { $0.sourceType },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { $0.sourceTitle },
                                     iconURLForTransaction: { $0.sourceIconURL },
                                     iconPlaceholderForTransaction: { $0.sourceType.defaultIconName(basketType: $0.basketType) },
                                     colorForTransaction: { self.incomeColor(for: $0) })
    }
    
    private func incomeKey(for transaction: TransactionViewModel) -> String {
        return "\(transaction.sourceType)_\(transaction.sourceId)"
    }
    
    
    private func incomeColor(for transaction: TransactionViewModel) -> UIColor? {
        if transaction.sourceType == .incomeSource {
            guard let idIndex = incomeSourceIds.firstIndex(of: transaction.sourceId) else { return nil }
            return colors.item(at: idIndex)
        }
        if transaction.sourceType == .active {
            guard let idIndex = activeIds.firstIndex(of: transaction.sourceId) else { return nil }
            return colors.item(at: idIndex + incomeSourceIds.count)
        }
        return nil
    }
}
