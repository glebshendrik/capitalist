//
//  GraphFiltersPresentingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

extension GraphViewModel {

    func calculateGraphFilters(for transactions: [TransactionViewModel],
                               currency: Currency?,
                               keyForTransaction: @escaping (TransactionViewModel) -> String,
                               transactionableIdForTransaction: @escaping (TransactionViewModel) -> Int,
                               transactionableTypeForTransaction: @escaping (TransactionViewModel) -> TransactionableType,
                               isVirtualTransactionable: @escaping (TransactionViewModel) -> Bool,
                               isBorrowOrReturnTransactionable: @escaping (TransactionViewModel) -> Bool,
                               amountForTransactions: @escaping ([TransactionViewModel]) -> NSDecimalNumber,
                               titleForTransaction: @escaping (TransactionViewModel) -> String,
                               iconURLForTransaction: @escaping (TransactionViewModel) -> URL?,
                               iconPlaceholderForTransaction: @escaping (TransactionViewModel) -> String?,
                               colorForTransaction: ((TransactionViewModel) -> UIColor?)? = nil,
                               coloringType: GraphTransactionFilterColoringType = .icon,
                               sortingType: GraphTransactionFilterSortingType = .percents) -> [GraphTransactionFilter] {
        
        guard let currency = currency else { return [] }
        
        let total = amountForTransactions(transactions)
        
        func graphTransactionFilter(transactions: [TransactionViewModel]) -> GraphTransactionFilter? {
        
            guard let transaction = transactions.first else { return nil }
                        
            let id = transactionableIdForTransaction(transaction)
            let type = transactionableTypeForTransaction(transaction)
            let isVirtualTransactionable = isVirtualTransactionable(transaction)
            let isBorrowOrReturnTransactionable = isBorrowOrReturnTransactionable(transaction)
            let title = titleForTransaction(transaction)
            let iconURL = iconURLForTransaction(transaction)
            let iconPlaceholder = iconPlaceholderForTransaction(transaction)
            let amount = amountForTransactions(transactions)
            let percents = amount.multiplying(byPowerOf10: 2).dividing(by: total)
            let color = colorForTransaction?(transaction) ?? randomColor(hue: .random, luminosity: .dark)
            
            return GraphTransactionFilter(id: id,
                                          type: type,
                                          isVirtualTransactionable: isVirtualTransactionable,
                                          isBorrowOrReturnTransactionable: isBorrowOrReturnTransactionable,
                                          title: title,
                                          iconURL: iconURL,
                                          iconPlaceholder: iconPlaceholder,
                                          сurrency: currency,
                                          amount: amount,
                                          percents: percents,
                                          color: color,
                                          coloringType: coloringType)            
        }
        
        var filters = transactions
                        .groupByKey { keyForTransaction($0) }
                        .compactMap { graphTransactionFilter(transactions: $0.value) }
        
        let borrowOrReturnFilters = filters.filter { $0.isBorrowOrReturnTransactionable }
        let virtualFilters = filters.filter { $0.isVirtualTransactionable }
        filters.removeAll { $0.isBorrowOrReturnTransactionable || $0.isVirtualTransactionable }
        
        if let borrowOrReturnFilter = borrowOrReturnFilters.sorted(by: { $0.percents.doubleValue >= $1.percents.doubleValue }).first {
            
            let amount = borrowOrReturnFilters.map { $0.amount }.reduce(NSDecimalNumber(integerLiteral: 0), { $0.adding($1) })
            let percents = borrowOrReturnFilters.map { $0.percents }.reduce(NSDecimalNumber(integerLiteral: 0), { $0.adding($1) })
            
            let compoundBorrowFilter = CompoundGraphTransactionFilter(id: borrowOrReturnFilter.id,
                                                                      type: borrowOrReturnFilter.type,
                                                                      isVirtualTransactionable: borrowOrReturnFilter.isVirtualTransactionable,
                                                                      isBorrowOrReturnTransactionable: borrowOrReturnFilter.isBorrowOrReturnTransactionable,
                                                                      title: borrowOrReturnFilter.title,
                                                                      iconURL: borrowOrReturnFilter.iconURL,
                                                                      iconPlaceholder: borrowOrReturnFilter.iconPlaceholder,
                                                                      сurrency: borrowOrReturnFilter.currency,
                                                                      amount: amount,
                                                                      percents: percents,
                                                                      color: borrowOrReturnFilter.color,
                                                                      coloringType: borrowOrReturnFilter.coloringType,
                                                                      filters: borrowOrReturnFilters)
            filters.append(compoundBorrowFilter)
        }
        
        if let virtualFilter = virtualFilters.sorted(by: { $0.percents.doubleValue >= $1.percents.doubleValue }).first {
            
            let amount = virtualFilters.map { $0.amount }.reduce(NSDecimalNumber(integerLiteral: 0), { $0.adding($1) })
            let percents = virtualFilters.map { $0.percents }.reduce(NSDecimalNumber(integerLiteral: 0), { $0.adding($1) })
            
            let compoundVirtualFilter = CompoundGraphTransactionFilter(id: virtualFilter.id,
                                                                      type: virtualFilter.type,
                                                                      isVirtualTransactionable: virtualFilter.isVirtualTransactionable,
                                                                      isBorrowOrReturnTransactionable: virtualFilter.isBorrowOrReturnTransactionable,
                                                                      title: NSLocalizedString("Не распределено", comment: ""),
                                                                      iconURL: virtualFilter.iconURL,
                                                                      iconPlaceholder: virtualFilter.iconPlaceholder,
                                                                      сurrency: virtualFilter.currency,
                                                                      amount: amount,
                                                                      percents: percents,
                                                                      color: virtualFilter.color,
                                                                      coloringType: virtualFilter.coloringType,
                                                                      filters: virtualFilters)
            filters.append(compoundVirtualFilter)
        }
        
        
        switch sortingType {
        case .id:
            return filters.sorted { $0.id <= $1.id }
        case .percents:
            return filters.sorted { $0.percents.doubleValue >= $1.percents.doubleValue }
        }
        
    }
    
    func graphFilterViewModel(at index: Int) -> GraphTransactionFilter? {
        return graphFilters[safe: index]
    }
    
    func canFilterTransactions(with filter: GraphTransactionFilter) -> Bool {
        return graphType != .all
    }
    
    func handleIncomeAndExpensesFilterTap(with filter: GraphTransactionFilter) {
        guard graphType == .all,
              let type = typeBy(incomeAndExpensesId: filter.id) else { return }
        switch type {
        case .income:
            graphType = .incomes
        case .expense:
            graphType = .expenses
        default:
            return
        }
    }
    
}
