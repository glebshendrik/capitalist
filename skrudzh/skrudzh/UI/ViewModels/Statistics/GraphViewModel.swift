//
//  GraphViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift

enum GraphType {
    case income
    case incomePie
    case expenses
    case expensesPie
    case incomeAndExpenses
    case cashFlow
    case netWorth
}

enum GraphPeriodScale {
    case days
    case weeks
    case months
    case quarters
    case years
    
    var asUnit: Calendar.Component {
        switch self {
        case .days:
            return .day
        case .weeks:
            return .weekOfYear
        case .months:
            return .month
        case .quarters:
            return .quarter
        case .years:
            return .year
        }
    }
}

class GraphViewModel {
    private let historyTransactionsViewModel: HistoryTransactionsViewModel
    
    private var transactions: [HistoryTransactionViewModel] {
        return historyTransactionsViewModel.filteredHistoryTransactionViewModels
    }
    
    private var dataPoints: [Date] = []
    
    var maxDataPoint: Double {
        return Double(dataPoints.last?.timeIntervalSince1970 ?? 0.0)
    }
    
    var minDataPoint: Double {
        return Double(dataPoints.first?.timeIntervalSince1970 ?? 0.0)
    }
    
    var numberOfDataPoints: Int {
        return dataPoints.count
    }
    
    var granularity: Double {
        guard numberOfDataPoints > 1 else { return 1.0 }
        return dataPoints[1].timeIntervalSince1970 - dataPoints[0].timeIntervalSince1970
    }
    
    var graphType: GraphType = .income {
        didSet {
            updateChartsData()
        }
    }
    
    var graphPeriodScale: GraphPeriodScale = .days {
        didSet {
            updateChartsData()
        }
    }
    
    var currency: Currency? {
        return historyTransactionsViewModel.defaultCurrency
    }
    
    public private(set) var incomeChartData: LineChartData? = nil
    
    init(historyTransactionsViewModel: HistoryTransactionsViewModel) {
        self.historyTransactionsViewModel = historyTransactionsViewModel
    }
    
    func updateChartsData() {
        updateDataPoints()
        
        switch graphType {
        case .income:
            updateIncomeChartData()
        case .incomePie:
            updateIncomePieChartData()
        case .expenses:
            updateExpensesChartData()
        case .expensesPie:
            updateExpensesPieChartData()
        case .incomeAndExpenses:
            updateIncomeAndExpensesChartData()
        case .cashFlow:
            updateCashFlowChartData()
        case .netWorth:
            updateNetWorthChartData()
        }
    }
    
    private func updateDataPoints() {
        var range = datesRange(from: transactions.last?.gotAt.dateAtStartOf(graphPeriodScale.asUnit),
                               to: transactions.first?.gotAt.dateAtStartOf(graphPeriodScale.asUnit))
        if  range.count == 1,
            let first = range.first,
            let date = Calendar.current.date(byAdding: graphPeriodScale.asUnit, value: -1, to: first) {
            
            range.insert(date, at: 0)
        }
        dataPoints = range
    }
    
    private func datesRange(from: Date?, to: Date?) -> [Date] {
        guard   let from = from,
                let to = to,
                to >= from else {
        
                    
                    return [Date]()
                }
        
        var tempDate = from
        var array = [tempDate]
        
        while tempDate < to {
            guard let nextDate = Calendar.current.date(byAdding: graphPeriodScale.asUnit, value: 1, to: tempDate) else {
                return [Date]()
            }
            tempDate = nextDate
            array.append(tempDate)
        }
        
        return array
    }
    
    private func updateIncomeChartData() {
        guard let currency = currency else { return }
        
        var incomeSourceDataSets: [Int : LineChartDataSet] = [:]
        var incomeSourceSums: [Int : Double] = [:]
        var valuesHash = [Date : [Int: Double]]()
        
        let incomeTransactions = transactions.filter { $0.transactionableType == .income }
        
        let incomeTransactionsByDateGroups = incomeTransactions.groupByKey { $0.gotAt.dateAtStartOf(graphPeriodScale.asUnit) }
        
        for incomeTransactionsByDateGroup in incomeTransactionsByDateGroups {
            let date = incomeTransactionsByDateGroup.key
            let incomeTransactionsByDate = incomeTransactionsByDateGroup.value
            
            if valuesHash[date] == nil {
                valuesHash[date] = [Int: Double]()
            }
            
            let incomeTransactionsByDateAndIncomeSourceGroups = incomeTransactionsByDate.groupByKey { $0.sourceId }
            
            for incomeTransactionsByDateAndIncomeSourceGroup in incomeTransactionsByDateAndIncomeSourceGroups {
                
                let incomeSourceId = incomeTransactionsByDateAndIncomeSourceGroup.key
                let incomeTransactionsByDateAndIncomeSource = incomeTransactionsByDateAndIncomeSourceGroup.value
                
                let value = historyTransactionsViewModel.historyTransactionsAmount(transactions: incomeTransactionsByDateAndIncomeSource).doubleValue
                
                valuesHash[date]?[incomeSourceId] = value
                
                incomeSourceSums[incomeSourceId] = (incomeSourceSums[incomeSourceId] ?? 0.0) + value
                
                if let incomeSourceTitle = incomeTransactionsByDateAndIncomeSource.first?.sourceTitle,
                    incomeSourceDataSets[incomeSourceId] == nil {
                    let dataSet = LineChartDataSet(values: [], label: incomeSourceTitle)
                    dataSet.drawFilledEnabled = true
                    
                    dataSet.lineWidth = 1
                    dataSet.circleRadius = 0
                    dataSet.drawCircleHoleEnabled = false
                    dataSet.drawValuesEnabled = false
                    dataSet.fillAlpha = 1.0
                    dataSet.mode = .horizontalBezier
                    let color = randomColor(hue: .random, luminosity: .random)
                    dataSet.fillColor = color
                    dataSet.colors = [color]
                    dataSet.drawHorizontalHighlightIndicatorEnabled = false
                    dataSet.drawVerticalHighlightIndicatorEnabled = false
                    incomeSourceDataSets[incomeSourceId] = dataSet
                    
                    
                }
                
            }
            
        }
        
        let incomeSourcesOrdered : [Int] = incomeSourceDataSets.keys.sorted { (left, right) -> Bool in
            return (incomeSourceSums[left] ?? 0.0) <= (incomeSourceSums[right] ?? 0.0)
        }
        
        for date in dataPoints {
            var valueAccumulator = 0.0
            for incomeSourceId in incomeSourcesOrdered {
                if let dataSet = incomeSourceDataSets[incomeSourceId] {
                    
                    let value: Double = valueAccumulator + (valuesHash[date]?[incomeSourceId] ?? 0.0)
                    let entry = ChartDataEntry(x: date.timeIntervalSince1970, y: value, data: date as AnyObject)
                    
                    _ = dataSet.addEntryOrdered(entry)
                    
                    valueAccumulator = value
                }
            }
            
        }
        let sorderDataSets = incomeSourcesOrdered.compactMap { incomeSourceDataSets[$0] }
        
        for i in 0 ..< sorderDataSets.count {
            if let previousDataSet = sorderDataSets.item(at: i - 1) {
                sorderDataSets[i].fillFormatter = AreaFillFormatter(fillLineDataSet: previousDataSet)
            }
        }
        
//        LineChartDataSet
        incomeChartData = LineChartData(dataSets: sorderDataSets)
        
        incomeChartData?.setValueFormatter(CurrencyValueFormatter(currency: currency))
    }

    private func updateIncomePieChartData() {
        
    }
    
    private func updateExpensesChartData() {
        
    }
    
    private func updateExpensesPieChartData() {
        
    }
    
    private func updateIncomeAndExpensesChartData() {
        
    }
    
    private func updateCashFlowChartData() {
        
    }
    
    private func updateNetWorthChartData() {
        
    }
}

public class CurrencyValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    
    let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
    }
    
    fileprivate func format(value: Double) -> String {
        
        let amount = NSDecimalNumber(floatLiteral: value)
        
        return amount.moneyCurrencyString(with: currency, shouldRound: true) ?? amount.stringValue
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return format(value: value)
    }
    
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        return format(value: value)
    }
}
