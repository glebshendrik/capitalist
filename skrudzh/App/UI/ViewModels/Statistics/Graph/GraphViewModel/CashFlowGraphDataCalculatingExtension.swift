//
//  CashFlowGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    func calculateCashFlowChartData() -> LineChartData? {
        return lineChartData(for: transactions,
                              currency: currency,
                              periodScale: graphPeriodScale,
                              keyForTransaction: { self.key(for: $0) },
                              amountForTransactions: { self.getAmount(for: $0) },
                              titleForTransaction: { self.title(for: $0) },
                              accumulateValuesHistory: true,
                              accumulateValuesForDate: false,
                              fillDataSetAreas: false,
                              colorForTransaction: { self.color(for: $0) },
                              oppositeKeyForTransaction: { self.oppositeKey(for: $0) },
                              oppositeAmountForTransactions: { self.oppositeAmount(for: $0) },
                              oppositeTitleForTransaction: { self.oppositeTitle(for: $0) })
    }
    
    func calculateCashflowFilters() -> [GraphHistoryTransactionFilter] {
        
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     periodScale: graphPeriodScale,
                                     keyForTransaction: { self.key(for: $0) },
                                     amountForTransactions: { self.getAmount(for: $0) },
                                     titleForTransaction: { self.title(for: $0) },
                                     accumulateValuesHistory: true,
                                     filterType: .expenseSource,
                                     colorForTransaction: { self.color(for: $0) },
                                     oppositeKeyForTransaction: { self.oppositeKey(for: $0) },
                                     oppositeAmountForTransactions: { self.oppositeAmount(for: $0) },
                                     oppositeTitleForTransaction: { self.oppositeTitle(for: $0) })
    }
    
    private func key(for transaction: HistoryTransactionViewModel) -> Int {
        switch transaction.transactionableType {
        case .expense:      return transaction.sourceId
        case .income:       return transaction.destinationId
        case .fundsMove:    return transaction.destinationId
        }
    }
    
    private func oppositeKey(for transaction: HistoryTransactionViewModel) -> Int {
        switch transaction.transactionableType {
        case .expense:      return transaction.sourceId
        case .income:       return transaction.destinationId
        case .fundsMove:    return transaction.sourceId
        }
    }
    
    private func title(for transaction: HistoryTransactionViewModel) -> String {
        switch transaction.transactionableType {
        case .expense:      return transaction.sourceTitle
        case .income:       return transaction.destinationTitle
        case .fundsMove:    return transaction.destinationTitle
        }
    }
    
    private func oppositeTitle(for transaction: HistoryTransactionViewModel) -> String {
        switch transaction.transactionableType {
        case .expense:      return transaction.sourceTitle
        case .income:       return transaction.destinationTitle
        case .fundsMove:    return transaction.sourceTitle
        }
    }
    
    
    private func getAmount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
        return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountForTransaction: { transaction -> (cents: Int, currency: Currency) in
            switch transaction.transactionableType {
            case .expense:      return (cents: -transaction.amountCents, currency: transaction.currency)
            case .income:       return (cents: transaction.convertedAmountCents, currency: transaction.convertedCurrency)
            case .fundsMove:    return (cents: transaction.convertedAmountCents, currency: transaction.convertedCurrency)
            }
        })
    }
    
    private func oppositeAmount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
        return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountForTransaction: { transaction -> (cents: Int, currency: Currency) in
            switch transaction.transactionableType {
            case .expense:      return (cents: 0, currency: transaction.currency)
            case .income:       return (cents: 0, currency: transaction.currency)
            case .fundsMove:    return (cents: -transaction.amountCents, currency: transaction.currency)
            }
        })
    }
    
    private func color(for transaction: HistoryTransactionViewModel) -> UIColor? {
        guard let idIndex = expenseSourceIds.firstIndex(of: transaction.sourceId) else { return nil }
        return colors.item(at: idIndex)
    }
}
