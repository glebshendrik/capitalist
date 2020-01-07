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
        
        return ["e6194B", "3cb44b", "ffe119", "4363d8", "f58231", "911eb4", "42d4f4", "f032e6", "bfef45", "fabebe", "469990", "e6beff", "9A6324", "fffac8", "800000", "aaffc3", "808000", "ffd8b1", "000075", "a9a9a9"]
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
