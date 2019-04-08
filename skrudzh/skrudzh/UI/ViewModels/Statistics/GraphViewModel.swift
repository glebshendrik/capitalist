//
//  GraphViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts

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
        dataPoints = datesRange(from: transactions.last?.gotAt.dateAtStartOf(graphPeriodScale.asUnit),
                                to: transactions.first?.gotAt.dateAtStartOf(graphPeriodScale.asUnit))
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
                
                let value = historyTransactionsViewModel.historyTransactionsAmountMoney(transactions: incomeTransactionsByDateAndIncomeSource).doubleValue
                
                valuesHash[date]?[incomeSourceId] = value
                
                incomeSourceSums[incomeSourceId] = (incomeSourceSums[incomeSourceId] ?? 0.0) + value
                
                if let incomeSourceTitle = incomeTransactionsByDateAndIncomeSource.first?.sourceTitle,
                    incomeSourceDataSets[incomeSourceId] == nil {
                    let dataSet = LineChartDataSet(values: [], label: incomeSourceTitle)
                    dataSet.drawFilledEnabled = true
                    
                    dataSet.lineWidth = 1
                    dataSet.circleRadius = 0
                    dataSet.drawCircleHoleEnabled = false
                    dataSet.valueFont = UIFont(name: "Rubik-Regular", size: 12)!
                    dataSet.valueTextColor = .black
                    dataSet.drawValuesEnabled = false
                    dataSet.fillAlpha = 1.0
                    dataSet.mode = .horizontalBezier
                    let color = ChartColorTemplates.colorful().randomItem ?? .red
                    dataSet.fillColor = color
                    dataSet.colors = [color]
                    incomeSourceDataSets[incomeSourceId] = dataSet
                    
                }
                
            }
            
        }
        
        let incomeSourcesOrdered : [Int] = incomeSourceDataSets.keys.sorted { (left, right) -> Bool in
            return (incomeSourceSums[left] ?? 0.0) <= (incomeSourceSums[right] ?? 0.0)
        }
        
        for date in dataPoints {
            for incomeSourceId in incomeSourcesOrdered {
                var valueAccumulator = 0.0
                if let dataSet = incomeSourceDataSets[incomeSourceId] {
                    
                    let value: Double = valueAccumulator + (valuesHash[date]?[incomeSourceId] ?? 0.0)
                    
                    _ = dataSet.addEntryOrdered(ChartDataEntry(x: date.timeIntervalSince1970, y: value, data: date as AnyObject))
                    
                    valueAccumulator = value
                }
            }
            
        }
        let sorderDataSets = incomeSourcesOrdered.compactMap { incomeSourceDataSets[$0] }
        incomeChartData = LineChartData(dataSets: sorderDataSets)
        incomeChartData?.setValueFormatter(LargeValueFormatter(appendix: nil))        
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

private let MAX_LENGTH = 5

@objc protocol Testing123 { }

public class LargeValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    
    /// Suffix to be appended after the values.
    ///
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    public var suffix = ["", "k", "m", "b", "t"]
    
    /// An appendix text to be added at the end of the formatted value.
    public var appendix: String?
    
    public init(appendix: String? = nil) {
        self.appendix = appendix
    }
    
    fileprivate func format(value: Double) -> String {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1
        
        while sig >= 1000.0 && length < maxLength {
            sig /= 1000.0
            length += 1
        }
        
        var r = String(format: "%2.f", sig) + suffix[length]
        
        if let appendix = appendix {
            r += appendix
        }
        
        return r
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
