//
//  NetWorthGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    var profitKey: Int { return 0 }
    var capitalKey: Int { return 1 }
    
    private var profitTitle: String { return "Чистый доход" }
    private var capitalTitle: String { return "Капитал" }
    
    private var profitColor: UIColor { return Color.Material.green }
    private var capitalColor: UIColor { return Color.Material.blue }
    
    func calculateNetWorthChartData() -> LineChartData? {
        guard let lineChartData = calculateIncomeAndExpensesChartData() else { return nil }
                
        let identifiedDataSets : [IdentifiedLineChartDataSet] = lineChartData.dataSets.compactMap { $0 as? IdentifiedLineChartDataSet }
        
        guard   let expensesDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .expense) }),
            let incomeDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .income) }) else { return nil }
        
        let profitDataSet = createLineChartDataSet(key: profitKey, title: profitTitle, shouldFill: false, color: profitColor)
        let capitalDataSet = createLineChartDataSet(key: capitalKey, title: capitalTitle, shouldFill: false, color: capitalColor)
        
        var capitalValue: Double = 0.0
        
        for i in 0 ..< numberOfDataPoints {
            
            guard let expenseDataEntry = expensesDataSet.values.item(at: i),
                let incomeDataEntry = incomeDataSet.values.item(at: i) else { return nil }
            
            let x = expenseDataEntry.x
            let profitValue = incomeDataEntry.y - expenseDataEntry.y
            capitalValue += profitValue
            
            _ = profitDataSet.addEntryOrdered(ChartDataEntry(x: x, y: profitValue))
            _ = capitalDataSet.addEntryOrdered(ChartDataEntry(x: x, y: capitalValue))
        }
        
        lineChartData.clearValues()
        lineChartData.addDataSet(profitDataSet)
        lineChartData.addDataSet(capitalDataSet)
        lineChartData.notifyDataChanged()
        
        return lineChartData
    }
    
    func calculateNetWorthFilters() -> [GraphHistoryTransactionFilter] {
        
        guard let currency = currency else { return [] }
        
        guard let lineChartData = calculateNetWorthChartData() else { return [] }
        
        let identifiedDataSets : [IdentifiedLineChartDataSet] = lineChartData.dataSets.compactMap { $0 as? IdentifiedLineChartDataSet }
        
        guard   let profitDataSet = identifiedDataSets.first(where: { $0.key == self.profitKey }),
            let capitalDataSet = identifiedDataSets.first(where: { $0.key == capitalKey }) else { return [] }
        
        let profitFilter = GraphHistoryTransactionFilter(id: profitKey, title: profitTitle, type: .expenseSource, color: profitColor, сurrency: currency)
        let capitalFilter = GraphHistoryTransactionFilter(id: capitalKey, title: capitalTitle, type: .expenseSource, color: capitalColor, сurrency: currency)
        
        
        for i in 0 ..< numberOfDataPoints {
            
            guard let profitDataEntry = profitDataSet.values.item(at: i),
                let capitalDataEntry = capitalDataSet.values.item(at: i),
                let date = dataPoints.item(at: i) else { return [] }
            
            profitFilter.values[date] = profitDataEntry.y
            capitalFilter.values[date] = capitalDataEntry.y
        }
        
        
        var filters = [Int : GraphHistoryTransactionFilter]()
        
        filters[profitKey] = profitFilter
        filters[capitalKey] = capitalFilter
        
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
}

