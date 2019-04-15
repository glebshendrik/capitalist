//
//  GraphDataPresentingAttributesExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
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
    
    var currency: Currency? {
        return historyTransactionsViewModel.defaultCurrency
    }
    
    var numberOfDataPoints: Int {
        return dataPoints.count
    }
    
    var hasData: Bool {
        return numberOfDataPoints > 0
    }
    
    var minDataPoint: Double? {
        guard let date = dataPoints.first else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var maxDataPoint: Double? {
        guard let date = dataPoints.last else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var lineChartCurrentPointDate: Date? {
        guard let point = lineChartCurrentPoint else { return nil }
        return Date(timeIntervalSince1970: point)
    }
    
    var lineChartCurrentPointWithOffset: Double? {
        guard let point = lineChartCurrentPoint else { return nil }
        return point - visibleXRangeMaximum / 2.0
    }
    
    var isLineChartCurrentPositionMarkerHidden: Bool {
        return lineChartHidden || !hasData
    }
    
    var granularity: Double {
        guard numberOfDataPoints > 1 else { return 1.0 }
        return (dataPoints[1].timeIntervalSince1970 - dataPoints[0].timeIntervalSince1970)
    }
    
    var labelsCount: Int {
        return numberOfDataPoints < 5 ? numberOfDataPoints : 5
    }
    
    var visibleXRangeMaximum: Double {
        guard numberOfDataPoints > 1 else { return 1.0 }
        return Double(labelsCount - 1) * granularity
    }
    
    var shouldLimitMinimumValueToZero: Bool {
        switch graphType {
        case .income,
             .expenses,
             .incomeAndExpenses:
            return true
        default:
            return false
        }
    }
    
    var dateFormat: String {
        return graphPeriodScale.dateFormat
    }
    
    var linePieChartSwitchHidden: Bool {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie:
            return false
        default:
            return true
        }
    }
    
    var linePieChartSwitchIconName: String? {
        switch graphType {
        case .income, .expenses:
            return "pie-chart-icon"
        case .incomePie, .expensesPie:
            return "line-chart-icon"
        default:
            return nil
        }
    }
    
    var lineChartHidden: Bool {
        switch graphType {
        case .incomePie, .expensesPie:
            return true
        default:
            return false
        }
    }
    
    var pieChartHidden: Bool {
        switch graphType {
        case .incomePie, .expensesPie:
            return false
        default:
            return true
        }
    }
    
    var numberOfPieCharts: Int {
        return pieChartDatas.count
    }
    
    var colors: [UIColor] {
        
        return ["e6194B", "3cb44b", "ffe119", "4363d8", "f58231", "911eb4", "42d4f4", "f032e6", "bfef45", "fabebe", "469990", "e6beff", "9A6324", "fffac8", "800000", "aaffc3", "808000", "ffd8b1", "000075", "a9a9a9"]
            .map { UIColor(hexString: $0) }
            .compactMap  { $0 }        
    }
    
    func pieChartViewModel(at indexPath: IndexPath) -> PieChartViewModel? {
        guard   let data = pieChartData(at: indexPath),
                let date = formattedDataPoint(at: indexPath),
                let amount = pieChartAmount(at: indexPath) else { return nil }
        return PieChartViewModel(chartData: data, date: date, amount: amount)
    }
    
    func pieChartData(at indexPath: IndexPath) -> PieChartData? {
        return pieChartDatas.item(at: indexPath.item)
    }
    
    func pieChartAmount(at indexPath: IndexPath) -> String? {
        return pieChartsAmounts.item(at: indexPath.item)
    }
    
    func formattedDataPoint(at indexPath: IndexPath) -> String? {
        return dataPoints.item(at: indexPath.item)?.string(withFormat: dateFormat)
    }
    
    func switchLinePieChart() {
        
        func graphTypeForLinePieSwitch() -> GraphType {
            switch graphType {
            case .income:
                return .incomePie
            case .incomePie:
                return .income
            case .expenses:
                return .expensesPie
            case .expensesPie:
                return .expenses
            default:
                return graphType
            }
        }
        
        graphType = graphTypeForLinePieSwitch()
    }
}
