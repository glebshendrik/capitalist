//
//  GraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

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

extension GraphViewModel {
    
    func datesRange(from: Date?, to: Date?) -> [Date] {
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
    
    func amount(for transactions: [HistoryTransactionViewModel]) -> NSDecimalNumber {
        return historyTransactionsViewModel.historyTransactionsAmount(transactions: transactions)
    }
    
    func lineChartData(for transactions: [HistoryTransactionViewModel],
                       currency: Currency?,
                       periodScale: GraphPeriodScale,
                       keyForTransaction: @escaping (HistoryTransactionViewModel) -> Int,
                       amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber,
                       titleForTransaction: @escaping (HistoryTransactionViewModel) -> String,
                       accumulateValuesHistory: Bool,
                       accumulateValuesForDate: Bool,
                       fillDataSetAreas: Bool,
                       colorForTransaction: ((HistoryTransactionViewModel) -> UIColor?)? = nil,
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
                    
                    dataSets[key] = createLineChartDataSet(key: key, title: title, shouldFill: fillDataSetAreas, color: color, isEven: dataSets.count.isEven)
                    
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
    
    func createLineChartDataSet(key: Int,
                       title: String,
                       shouldFill: Bool = true,
                       color: UIColor? = nil,
                       isEven: Bool = false) -> IdentifiedLineChartDataSet {
        
        let dataSet = IdentifiedLineChartDataSet(values: [], label: title, key: key)
        
        dataSet.drawFilledEnabled = shouldFill
        
        dataSet.lineWidth = shouldFill ? 1.0 : 4.0
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.fillAlpha = 0.85
        dataSet.mode = .horizontalBezier
        dataSet.resetColors()
        
        let color = color ?? randomColor(hue: .random, luminosity: isEven ? .dark : .light)
        dataSet.fillColor = color
        dataSet.colors = [color]
        
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        
        return dataSet
    }
    
    
}
