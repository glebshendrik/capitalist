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
    
    func pieChartData(at indexPath: IndexPath) -> PieChartData? {
        return pieChartDatas.item(at: indexPath.item)
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
