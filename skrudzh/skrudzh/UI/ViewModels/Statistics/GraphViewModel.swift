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
import SwifterSwift

enum GraphType {
    case income
    case incomePie
    case expenses
    case expensesPie
    case incomeAndExpenses
    case cashFlow
    case netWorth
    
    static var switchList: [GraphType] {
        return [.income, .expenses, .incomeAndExpenses, .cashFlow, .netWorth]
    }
    
    var title: String {
        switch self {
        case .income:
            return "Доход"
        case .incomePie:
            return "Доход"
        case .expenses:
            return "Расходы"
        case .expensesPie:
            return "Расходы"
        case .incomeAndExpenses:
            return "Доход и Расходы"
        case .cashFlow:
            return "Кошельки"
        case .netWorth:
            return "Накопления"
        }
    }
}

enum GraphPeriodScale {
    case days
    case weeks
    case months
    case quarters
    case years
    
    static var switchList: [GraphPeriodScale] {
        return [.days, .weeks, .months, .quarters, .years]
    }
    
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
    
    var addingUnit: Calendar.Component {
        if case .quarters = self {
            return .month
        }
        return asUnit
    }
    
    var addingValue: Int {
        if case .quarters = self {
            return 3
        }
        return 1
    }
    
    var dateFormat: String {
        switch self {
        case .days,
             .weeks:
            return "dd.MM.yy"
        case .months:
            return "MMM, yy"
        case .quarters:
            return "Q`yy"
        case .years:
            return "yyyy"
        }
    }
    
    var title: String {
        switch self {
        case .days:
            return "Дни"
        case .weeks:
            return "Недели"
        case .months:
            return "Месяцы"
        case .quarters:
            return "Кварталы"
        case .years:
            return "Годы"
        }
    }
}

class GraphViewModel {
    private let historyTransactionsViewModel: HistoryTransactionsViewModel
    
    private var transactions: [HistoryTransactionViewModel] {
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
    
    private var dataPoints: [Date] = [] {
        didSet {
            lineChartCurrentPoint = maxDataPoint
        }
    }
    
    var maxDataPoint: Double? {
        guard let date = dataPoints.last else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var minDataPoint: Double? {
        guard let date = dataPoints.first else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var hasData: Bool {
        return numberOfDataPoints > 0
    }
    
    var numberOfDataPoints: Int {
        return dataPoints.count
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
    
    var graphType: GraphType = .incomeAndExpenses {
        didSet {
            updateChartsData()
        }
    }
    
    var graphPeriodScale: GraphPeriodScale = .days {
        didSet {
            updateChartsData()
        }
    }
    
    var dateFormat: String {
        return graphPeriodScale.dateFormat
    }
    
    var currency: Currency? {
        return historyTransactionsViewModel.defaultCurrency
    }
    
    var lineChartCurrentPoint: Double? = nil
    
    var lineChartCurrentPointDate: Date? {
        guard let point = lineChartCurrentPoint else { return nil }
        return Date(timeIntervalSince1970: point)
    }
    
    var lineChartCurrentPointWithOffset: Double? {
        guard let point = lineChartCurrentPoint else { return nil }
        return point - visibleXRangeMaximum / 2.0
    }
    
    public private(set) var lineChartData: LineChartData? = nil
    public private(set) var incomePieChartData: LineChartData? = nil
    public private(set) var expensesPieChartData: LineChartData? = nil
    
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
            let date = Calendar.current.date(byAdding: graphPeriodScale.addingUnit, value: -graphPeriodScale.addingValue, to: first) {

            range.insert(date, at: 0)
        }
        
        dataPoints = range
    }
    
    private func updateIncomeChartData() {
        lineChartData = lineChartData(for: transactions,
                                        currency: currency,
                                        periodScale: graphPeriodScale,
                                        keyForTransaction: { $0.sourceId },
                                        amountForTransactions: { self.amount(for: $0) },
                                        titleForTransaction: { $0.sourceTitle },
                                        accumulateValuesHistory: false,
                                        accumulateValuesForDate: true,
                                        fillDataSetAreas: true)
    }
    
    private func updateIncomePieChartData() {
        
    }
    
    private func updateExpensesChartData() {
        lineChartData = lineChartData(for: transactions,
                                      currency: currency,
                                      periodScale: graphPeriodScale,
                                      keyForTransaction: { $0.destinationId },
                                      amountForTransactions: { self.amount(for: $0) },
                                      titleForTransaction: { $0.destinationTitle },
                                      accumulateValuesHistory: false,
                                      accumulateValuesForDate: true,
                                      fillDataSetAreas: true)
    }
    
    
    
    private func updateExpensesPieChartData() {
        
    }
    
    private func incomeAndExpensesDataSetKey(by transactionableType: TransactionableType) -> Int {
        switch transactionableType {
        case .expense:      return 0
        case .income:       return 1
        case .fundsMove:    return 2
        }
    }
    
    private func updateIncomeAndExpensesChartData() {
        
        func title(by transactionableType: TransactionableType) -> String {
            switch transactionableType {
            case .expense:      return "Расходы"
            case .income:       return "Доход"
            case .fundsMove:    return "Переводы"
            }
        }
        
        func color(by transactionableType: TransactionableType) -> UIColor {
            switch transactionableType {
            case .expense:      return .red
            case .income:       return Color.Material.green
            case .fundsMove:    return .blue
            }
        }
        
        lineChartData = lineChartData(for: transactions,
                                       currency: currency,
                                       periodScale: graphPeriodScale,
                                       keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.transactionableType) },
                                       amountForTransactions: { self.amount(for: $0) },
                                       titleForTransaction: { title(by: $0.transactionableType) },
                                       accumulateValuesHistory: false,
                                       accumulateValuesForDate: false,
                                       fillDataSetAreas: false,
                                       colorForTransaction: { color(by: $0.transactionableType) })
    }
    
    private func updateCashFlowChartData() {
        
        func key(for transaction: HistoryTransactionViewModel) -> Int {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceId
            case .income:       return transaction.destinationId
            case .fundsMove:    return transaction.destinationId
            }
        }
        
        func title(for transaction: HistoryTransactionViewModel) -> String {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceTitle
            case .income:       return transaction.destinationTitle
            case .fundsMove:    return transaction.destinationTitle
            }
        }
        
        func oppositeKey(for transaction: HistoryTransactionViewModel) -> Int {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceId
            case .income:       return transaction.destinationId
            case .fundsMove:    return transaction.sourceId
            }
        }
        
        func oppositeTitle(for transaction: HistoryTransactionViewModel) -> String {
            switch transaction.transactionableType {
            case .expense:      return transaction.sourceTitle
            case .income:       return transaction.destinationTitle
            case .fundsMove:    return transaction.sourceTitle
            }
        }
        
        func amount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
            return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountCentsForTransaction: { transaction -> Int in
                switch transaction.transactionableType {
                case .expense:      return -transaction.amountCents
                case .income:       return transaction.amountCents
                case .fundsMove:    return transaction.amountCents
                }
            })
        }
        
        func oppositeAmount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
            return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions, amountCentsForTransaction: { transaction -> Int in
                switch transaction.transactionableType {
                case .expense:      return 0
                case .income:       return 0
                case .fundsMove:    return -transaction.amountCents
                }
            })
        }
        
        lineChartData = lineChartData(for: transactions,
                                      currency: currency,
                                      periodScale: graphPeriodScale,
                                      keyForTransaction: { key(for: $0) },
                                      amountForTransactions: { amount(for: $0) },
                                      titleForTransaction: { title(for: $0) },
                                      accumulateValuesHistory: true,
                                      accumulateValuesForDate: false,
                                      fillDataSetAreas: false,
                                      colorForTransaction: nil,
                                      oppositeKeyForTransaction: { oppositeKey(for: $0) },
                                      oppositeAmountForTransactions: { oppositeAmount(for: $0) },
                                      oppositeTitleForTransaction: { oppositeTitle(for: $0) })
    }
    
    let profitKey: Int = 0
    let capitalKey: Int = 1
    
    private func updateNetWorthChartData() {
        updateIncomeAndExpensesChartData()
        
        guard   let lineChartData = lineChartData else { return }
        
        let identifiedDataSets : [IdentifiedLineChartDataSet] = lineChartData.dataSets.compactMap { $0 as? IdentifiedLineChartDataSet }
        
        guard   let expensesDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .expense) }),
                let incomeDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .income) }) else { return }
        
        let profitDataSet = createDataSet(key: profitKey, title: "Чистый доход", shouldFill: false, color: Color.Material.green)
        let capitalDataSet = createDataSet(key: capitalKey, title: "Капитал", shouldFill: false, color: Color.Material.blue)
        
        var capitalValue: Double = 0.0
        
        for i in 0 ..< numberOfDataPoints {
            
            guard let expenseDataEntry = expensesDataSet.values.item(at: i),
                let incomeDataEntry = incomeDataSet.values.item(at: i) else { return }
            
            let x = expenseDataEntry.x
            let profitValue = incomeDataEntry.y - expenseDataEntry.y
            capitalValue += profitValue
            
            _ = profitDataSet.addEntryOrdered(ChartDataEntry(x: x, y: profitValue))
            _ = capitalDataSet.addEntryOrdered(ChartDataEntry(x: x, y: capitalValue))
        }
        
        self.lineChartData?.clearValues()
        self.lineChartData?.addDataSet(profitDataSet)
        self.lineChartData?.addDataSet(capitalDataSet)
        self.lineChartData?.notifyDataChanged()
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
            guard let nextDate = Calendar.current.date(byAdding: graphPeriodScale.addingUnit, value: graphPeriodScale.addingValue, to: tempDate) else {
                return [Date]()
            }
            tempDate = nextDate
            array.append(tempDate)
        }
        
        return array
    }
    
    private func amount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
        return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions)
    }
    
    private func lineChartData(for transactions: [HistoryTransactionViewModel],
                               currency: Currency?,
                               periodScale: GraphPeriodScale,
                               keyForTransaction: @escaping (HistoryTransactionViewModel) -> Int,
                               amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber,
                               titleForTransaction: @escaping (HistoryTransactionViewModel) -> String,
                               accumulateValuesHistory: Bool,
                               accumulateValuesForDate: Bool,
                               fillDataSetAreas: Bool,
                               colorForTransaction: ((HistoryTransactionViewModel) -> UIColor)? = nil,
                               oppositeKeyForTransaction: ((HistoryTransactionViewModel) -> Int)? = nil,
                               oppositeAmountForTransactions: (([HistoryTransactionViewModel]) -> NSDecimalNumber)? = nil,
                               oppositeTitleForTransaction: ((HistoryTransactionViewModel) -> String)? = nil) -> LineChartData? {
        
        guard let currency = currency else { return nil }
        
        var dataSets: [Int : LineChartDataSet] = [:]
        var sums: [Int : Double] = [:]
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
                
                sums[key] = (sums[key] ?? 0.0) + value
                
                if let transaction = transactionsByDateAndKey.first,
                    case let title = titleFor(transaction),
                    dataSets[key] == nil {
                    
                    let color = colorForTransaction?(transaction) ?? nil
                    
                    dataSets[key] = createDataSet(key: key, title: title, shouldFill: fillDataSetAreas, color: color, isEven: dataSets.count.isEven)
                    
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
        
        let dataSetKeysOrdered : [Int] = dataSets.keys.sorted { (left, right) -> Bool in
            return (sums[left] ?? 0.0) <= (sums[right] ?? 0.0)
        }
        
        var valuesHistoryAccumulator: [Int : Double] = [:]
        
        for date in dataPoints {
            var valueDateAccumulator = 0.0
            for dataSetKey in dataSetKeysOrdered {
                if let dataSet = dataSets[dataSetKey] {
                    
                    let pureValue = valuesHash[date]?[dataSetKey] ?? 0.0
                    
                    let historyAccumulatedValue = valuesHistoryAccumulator[dataSetKey] ?? 0.0
                    
                    valuesHistoryAccumulator[dataSetKey] = historyAccumulatedValue + pureValue
                    
                    var value = pureValue
                    
                    if accumulateValuesForDate {
                         value += valueDateAccumulator
                    }
                    
                    if accumulateValuesHistory {
                        value += historyAccumulatedValue
                    }
                    
                    let entry = ChartDataEntry(x: date.timeIntervalSince1970, y: value, data: date as AnyObject)
                    
                    _ = dataSet.addEntryOrdered(entry)
                    
                    valueDateAccumulator = value
                }
            }
            
        }
        
        let dataSetsOrdered = dataSetKeysOrdered.compactMap { dataSets[$0] }
        
        if fillDataSetAreas {
            for i in 0 ..< dataSetsOrdered.count {
                if let previousDataSet = dataSetsOrdered.item(at: i - 1) {
                    dataSetsOrdered[i].fillFormatter = AreaFillFormatter(fillLineDataSet: previousDataSet)
                }
            }
        }
        
        
        let chartData = LineChartData(dataSets: dataSetsOrdered)
        
        chartData.setValueFormatter(CurrencyValueFormatter(currency: currency))
        
        return chartData
    }
    
    private func createDataSet(key: Int, title: String, shouldFill: Bool = true, color: UIColor? = nil, isEven: Bool = false) -> IdentifiedLineChartDataSet {
        
        let dataSet = IdentifiedLineChartDataSet(values: [], label: title, key: key)
        
        dataSet.drawFilledEnabled = shouldFill
        
        dataSet.lineWidth = shouldFill ? 1.0 : 4.0
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.fillAlpha = 0.85
        dataSet.mode = .horizontalBezier
        
        let color = color ?? randomColor(hue: .random, luminosity: isEven ? .dark : .light)
        dataSet.fillColor = color
        dataSet.colors = [color]
        
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = false

        return dataSet
    }
}

class IdentifiedLineChartDataSet : LineChartDataSet {
    let key: Int
    
    init(values: [ChartDataEntry]?, label: String?, key: Int) {
        self.key = key
        super.init(values: values, label: label)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
