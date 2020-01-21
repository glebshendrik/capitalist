//
//  GraphPresentingAttributesExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    var transactions: [TransactionViewModel] {
        let transactions = transactionsViewModel.filteredTransactionViewModels
        
        switch graphType {
        case .all:
            return transactions.filter { $0.type != .fundsMove }
        case .incomes:
            return incomes
        case .expenses:
            return expenses
        }
    }
    
    var incomes: [TransactionViewModel] {
        return transactionsViewModel.filteredTransactionViewModels.filter { $0.type == .income }
    }
    
    var expenses: [TransactionViewModel] {
        return transactionsViewModel.filteredTransactionViewModels.filter { $0.type == .expense }
    }
    
    var colors: [UIColor] {
        
        return ["ECB056", "EB6242", "E9544D", "E8476E", "C84C85", "B761C5", "8E5EE3", "3F5ABC", "2771AE", "3683EE", "1CC6DB", "1CB5A7", "30D38D", "5DBF5A", "6EBBB7", "738F9C", "FAC28A", "FF8164", "FC6D66", "F17391", "DD597D", "C469D2", "906FCB", "3F6FCC", "4E93CF", "5EB2F6", "49D5E7", "3CC0BC", "7FD89A", "7DC581", "94BCBA", "8CA1AB"]
            .map { UIColor(hexString: $0) }
            .compactMap  { $0 }
    }
        
    var incomeSourceIds: [Int] {
        return transactions
            .filter { $0.sourceType == TransactionableType.incomeSource }
            .map { $0.sourceId }
            .withoutDuplicates()
            .sorted()
    }
    
    var expenseSourceIds: [Int] {
        let asSources = transactions
            .filter { $0.sourceType == TransactionableType.expenseSource }
            .map { $0.sourceId }
        
        let asDestinations = transactions
            .filter { $0.destinationType == TransactionableType.expenseSource }
            .map { $0.destinationId }
        
        return (asSources + asDestinations).withoutDuplicates().sorted()
    }
    
    var expenseCategoryIds: [Int] {
        return transactions
            .filter { $0.destinationType == TransactionableType.expenseCategory }
            .map { $0.destinationId }
            .withoutDuplicates()
            .sorted()
    }
    
    var activeIds: [Int] {
        let asSources = transactions
            .filter { $0.sourceType == TransactionableType.active }
            .map { $0.sourceId }
        
        let asDestinations = transactions
            .filter { $0.destinationType == TransactionableType.active }
            .map { $0.destinationId }
        
        return (asSources + asDestinations).withoutDuplicates().sorted()
    }
            
    func amount(for transactions: [TransactionViewModel]) -> NSDecimalNumber {
        return transactionsViewModel.transactionsAmount(transactions: transactions)
    }
}
