//
//  CashFlowGraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    func calculateCashFlowChartData() -> LineChartData? {
        
        func key(for transaction: HistoryTransactionViewModel) -> Int {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceId
            case .income:       return transaction.destinationId
            case .fundsMove:    return transaction.destinationId
            }
        }
        
        func title(for transaction: HistoryTransactionViewModel) -> String {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceTitle
            case .income:       return transaction.destinationTitle
            case .fundsMove:    return transaction.destinationTitle
            }
        }
        
        func oppositeKey(for transaction: HistoryTransactionViewModel) -> Int {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceId
            case .income:       return transaction.destinationId
            case .fundsMove:    return transaction.sourceId
            }
        }
        
        func oppositeTitle(for transaction: HistoryTransactionViewModel) -> String {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceTitle
            case .income:       return transaction.destinationTitle
            case .fundsMove:    return transaction.sourceTitle
            }
        }
        
        func amount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
            return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountCentsForTransaction: { transaction -> Int in
                switch transaction.transactionableType {
                case .expense:      return -transaction.amountCents
                case .income:       return transaction.amountCents
                case .fundsMove:    return transaction.amountCents
                }
            })
        }
        
        func oppositeAmount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
            return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountCentsForTransaction: { transaction -> Int in
                switch transaction.transactionableType {
                case .expense:      return 0
                case .income:       return 0
                case .fundsMove:    return -transaction.amountCents
                }
            })
        }
        
        return lineChartData(for: transactions,
                              currency: currency,
                              periodScale: graphPeriodScale,
                              keyForTransaction: { key(for: $0) },
                              amountForTransactions: { amount(for: $0) },
                              titleForTransaction: { title(for: $0) },
                              accumulateValuesHistory: true,
                              accumulateValuesForDate: false,
                              fillDataSetAreas: false,
                              colorForTransaction: { self.color(for: $0) },
                              oppositeKeyForTransaction: { oppositeKey(for: $0) },
                              oppositeAmountForTransactions: { oppositeAmount(for: $0) },
                              oppositeTitleForTransaction: { oppositeTitle(for: $0) })
    }
    
    private func color(for transaction: HistoryTransactionViewModel) -> UIColor? {
        guard let idIndex = expenseSourceIds.firstIndex(of: transaction.sourceId) else { return nil }
        return colors.item(at: idIndex)
    }
}
