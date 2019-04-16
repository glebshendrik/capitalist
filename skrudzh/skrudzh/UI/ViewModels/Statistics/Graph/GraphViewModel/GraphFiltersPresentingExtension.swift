//
//  GraphFiltersPresentingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    
    var aggregationTypes: [AggregationType] {
        switch graphType {
        case .income, .incomePie:
            return [.percent, .total, .average, .maximum, .minimum]
        case .expenses, .expensesPie:
            return [.percent, .budget, .total, .average, .maximum, .minimum]
        case .incomeAndExpenses:
            return [.total, .average, .maximum, .minimum]
        case .cashFlow:
            return [.percent, .average, .maximum, .minimum]
        case .netWorth:
            return [.average, .maximum, .minimum]
        }
    }
    
    var shouldShowTotal: Bool {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie, .cashFlow:
            return true
        case .incomeAndExpenses, .netWorth:
            return false
        }
    }
    
    var shouldShowFiltersToggle: Bool {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie, .cashFlow:
            return true
        case .incomeAndExpenses, .netWorth:
            return false
        }
    }
    
    var filtersToggleText: String {
        return areGraphFiltersShown ? "Свернуть" : "Показать все"
    }
    
    var filtersToggleImageName: String {
        return areGraphFiltersShown ? "arrow-up-icon" : "arrow-down-icon"
    }
    
    func toggleFilters() {
        areGraphFiltersShown = !areGraphFiltersShown
    }
    
    func defaultAggregationType(for graphType: GraphType) -> AggregationType {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie, .incomeAndExpenses:
            return .total
        case .cashFlow:
            return .percent
        case .netWorth:
            return .average
        }
    }
    
    func updateAggregationType() {
        aggregationType = defaultAggregationType(for: graphType)
    }
    
    func updateGraphFilters() {
        graphFilters = []
    }
    
    var incomeSourceIds: [Int] {
        return transactions
            .filter { $0.sourceType == HistoryTransactionSourceOrDestinationType.incomeSource }
            .map { $0.sourceId }
            .withoutDuplicates()
            .sorted()
    }
    
    var expenseSourceIds: [Int] {
        let asSources = transactions
            .filter { $0.sourceType == HistoryTransactionSourceOrDestinationType.expenseSource }
            .map { $0.sourceId }
        
        let asDestinations = transactions
            .filter { $0.destinationType == HistoryTransactionSourceOrDestinationType.expenseSource }
            .map { $0.destinationId }
        
        return (asSources + asDestinations).withoutDuplicates().sorted()
    }
    
    var expenseCategoryIds: [Int] {
        return transactions
            .filter { $0.destinationType == HistoryTransactionSourceOrDestinationType.expenseCategory }
            .map { $0.destinationId }
            .withoutDuplicates()
            .sorted()
    }
}
