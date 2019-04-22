//
//  GraphFiltersPresentingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

extension GraphViewModel {
    
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
    
    var areGraphFiltersInteractable: Bool {
        return graphType != .netWorth
    }
    
    var aggregationTypes: [AggregationType] {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie:
            return [.percent, .total, .average, .maximum, .minimum]
        case .incomeAndExpenses:
            return [.total, .average, .maximum, .minimum]
        case .cashFlow, .netWorth:
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
        case .cashFlow, .netWorth:
            return .average
        }
    }
    
    func updateAggregationType() {
        aggregationType = defaultAggregationType(for: graphType)
    }
    
    func updateGraphFiltersVisibility() {
        if graphType == .incomeAndExpenses || graphType == .netWorth {
            areGraphFiltersShown = true
        }
    }
    
    func updateGraphFilters() {
        switch graphType {
        case .income, .incomePie:
            graphFilters = calculateIncomeFilters()
        case .expenses, .expensesPie:
            graphFilters = calculateExpensesFilters()
        case .cashFlow:
            graphFilters = calculateCashflowFilters()
        case .incomeAndExpenses:
            graphFilters = calculateIncomeAndExpensesFilters()
        case .netWorth:
            graphFilters = calculateNetWorthFilters()
        }        
        updateTotal()
        updateGraphFiltersAggregationType()
        updateGraphFiltersCurrentDate()
    }
    
    func updateAggregatedTotal() {
        filtersAggregatedTotal = graphFilters.compactMap { $0.aggregatedValues[aggregationType] }.reduce(0.0, +)
    }
    
    func updateTotal() {
        updateAggregatedTotal()
        filtersTotalByDate = [Date : Double]()
        for date in dataPoints {
            filtersTotalByDate[date] = graphFilters.compactMap { $0.values[date] }.reduce(0.0, +)            
        }
    }
    
    func updateGraphFiltersAggregationType() {
        graphFilters.forEach { $0.aggregationType = self.aggregationType }
    }
    
    func updateGraphFiltersCurrentDate() {
        graphFilters.forEach { $0.date = self.currentDate }
    }
    
    func calculateGraphFilters(for transactions: [HistoryTransactionViewModel],
                               currency: Currency?,
                               periodScale: GraphPeriodScale,
                               keyForTransaction: @escaping (HistoryTransactionViewModel) -> Int,
                               amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber,
                               titleForTransaction: @escaping (HistoryTransactionViewModel) -> String,
                               accumulateValuesHistory: Bool,
                               filterType: HistoryTransactionSourceOrDestinationType,
                               colorForTransaction: ((HistoryTransactionViewModel) -> UIColor?)? = nil,
                               oppositeKeyForTransaction: ((HistoryTransactionViewModel) -> Int)? = nil,
                               oppositeAmountForTransactions: (([HistoryTransactionViewModel]) -> NSDecimalNumber)? = nil,
                               oppositeTitleForTransaction: ((HistoryTransactionViewModel) -> String)? = nil) -> [GraphHistoryTransactionFilter] {
        
        guard let currency = currency else { return [] }
        
        var filters = [Int : GraphHistoryTransactionFilter]()
        var valuesHash = [Date : [Int: Double]]()
        
        func collectValues(for transactionsByDate: [HistoryTransactionViewModel],
                           date: Date,
                           keyFor: ((HistoryTransactionViewModel) -> Int)?,
                           amountFor: (([HistoryTransactionViewModel]) -> NSDecimalNumber)?,
                           titleFor: ((HistoryTransactionViewModel) -> String)?) {
            
            guard   let keyFor = keyFor,
                let amountFor = amountFor,
                let titleFor = titleFor else { return }
            
            let transactionsByDateAndKeyGroups = transactionsByDate.groupByKey { keyFor($0) }
            
            for transactionsByDateAndKeyGroup in transactionsByDateAndKeyGroups {
                
                let key = transactionsByDateAndKeyGroup.key
                let transactionsByDateAndKey = transactionsByDateAndKeyGroup.value
                
                let value = amountFor(transactionsByDateAndKey).doubleValue
                
                if valuesHash[date] != nil {
                    valuesHash[date]![key] = (valuesHash[date]![key] ?? 0.0) + value
                }
                
                if let transaction = transactionsByDateAndKey.first,
                    case let title = titleFor(transaction),
                    filters[key] == nil {
                    
                    let color = colorForTransaction?(transaction) ?? randomColor(hue: .random, luminosity: .dark)
                    
                    filters[key] = GraphHistoryTransactionFilter(id: key, title: title, type: filterType, color: color, сurrency: currency)
                    
                }
                
            }
        }
        
        let transactionsByDateGroups = transactions.groupByKey { $0.gotAt.dateAtStartOf(periodScale.asUnit) }
        
        for transactionsByDateGroup in transactionsByDateGroups {
            let date = transactionsByDateGroup.key
            let transactionsByDate = transactionsByDateGroup.value
            
            if valuesHash[date] == nil {
                valuesHash[date] = [Int: Double]()
            }
            
            collectValues(for: transactionsByDate,
                          date: date,
                          keyFor: keyForTransaction,
                          amountFor: amountForTransactions,
                          titleFor: titleForTransaction)
            
            collectValues(for: transactionsByDate,
                          date: date,
                          keyFor: oppositeKeyForTransaction,
                          amountFor: oppositeAmountForTransactions,
                          titleFor: oppositeTitleForTransaction)
            
        }
        
        var valuesHistoryAccumulator: [Int : Double] = [:]
        
        for date in dataPoints {
            for key in filters.keys {
                let pureValue = valuesHash[date]?[key] ?? 0.0
                
                let historyAccumulatedValue = valuesHistoryAccumulator[key] ?? 0.0
                
                valuesHistoryAccumulator[key] = historyAccumulatedValue + pureValue
                
                var value = pureValue
                
                if accumulateValuesHistory {
                    value += historyAccumulatedValue
                }
                
                filters[key]?.values[date] = value
            }
        }
        
        for filter in filters {
            let values = filter.value.values.map { $0.value }
            let total = values.reduce(0.0, +)
            let min = values.min() ?? 0.0
            let max = values.max() ?? 0.0
            let average = values.count > 0 ? (total / Double(values.count)) : 0.0
            filters[filter.key]?.aggregatedValues[AggregationType.total] = total
            filters[filter.key]?.aggregatedValues[AggregationType.minimum] = min
            filters[filter.key]?.aggregatedValues[AggregationType.maximum] = max
            filters[filter.key]?.aggregatedValues[AggregationType.average] = average
            filters[filter.key]?.aggregatedValues[AggregationType.percent] = 0.0
        }
        
        for date in dataPoints {
            let total = filters.values.compactMap { $0.values[date] }.reduce(0.0, +)
            for key in filters.keys {
                if let value = filters[key]?.values[date],
                    total > 0 {
                    let percents = value * 100.0 / total
                    filters[key]?.percents[date] = percents
                } else {
                    filters[key]?.percents[date] = 0.0
                }
            }
        }
                
        return filters.values.map { $0 }.sorted { $0.total >= $1.total }
    }
    
    func graphFilterViewModel(at index: Int) -> GraphHistoryTransactionFilter? {
        return graphFilters.item(at: index)
    }
    
    func canFilterTransactions(with filter: GraphHistoryTransactionFilter) -> Bool {
        return graphType != .incomeAndExpenses && graphType != .netWorth
    }
    
    func handleIncomeAndExpensesFilterTap(with filter: GraphHistoryTransactionFilter) {
        guard graphType == .incomeAndExpenses,
              let transactionableType = transactionableTypeBy(incomeAndExpensesDataSetKey: filter.id) else { return }
        switch transactionableType {
        case .income:
            graphType = .incomePie
        case .expense:
            graphType = .expensesPie
        default:
            return
        }
    }    
    
}
