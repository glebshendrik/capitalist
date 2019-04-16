//
//  GraphPresentingAttributesExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    
    var transactions: [HistoryTransactionViewModel] {
        let transactions = historyTransactionsViewModel.filteredHistoryTransactionViewModels
        
        switch graphType {
        case .income, .incomePie:
            return transactions.filter { $0.transactionableType == .income }
        case .expenses, .expensesPie:
            return transactions.filter { $0.transactionableType == .expense }
        case .incomeAndExpenses, .netWorth:
            return transactions.filter { $0.transactionableType != .fundsMove }
        case .cashFlow:
            return transactions
        }
    }
    
    var currency: Currency? {
        return historyTransactionsViewModel.defaultCurrency
    }
    
    var numberOfDataPoints: Int {
        return dataPoints.count
    }
    
    var hasData: Bool {
        return numberOfDataPoints > 0
    }
    
    var dateFormat: String {
        return graphPeriodScale.dateFormat
    }
    
    var colors: [UIColor] {
        
        return ["e6194B", "3cb44b", "ffe119", "4363d8", "f58231", "911eb4", "42d4f4", "f032e6", "bfef45", "fabebe", "469990", "e6beff", "9A6324", "fffac8", "800000", "aaffc3", "808000", "ffd8b1", "000075", "a9a9a9"]
            .map { UIColor(hexString: $0) }
            .compactMap  { $0 }
    }
    
    func formattedDataPoint(at indexPath: IndexPath) -> String? {
        return dataPoints.item(at: indexPath.item)?.string(withFormat: dateFormat)
    }
    
}
