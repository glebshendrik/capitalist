//
//  PieChartPresentingExtension.swift
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
    
    var pieChartCurrentPointDate: Date? {
        guard let index = currentPieChartIndex else { return nil }
        return dataPoints.item(at: index)
    }
    
    var numberOfPieCharts: Int {
        return pieChartDatas.count
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
    
    func pieChartsAmounts(for transactions: [HistoryTransactionViewModel],
                          currency: Currency?,
                          periodScale: GraphPeriodScale?,
                          amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber) -> [String] {
        
        guard   let currency = currency,
                let periodScale = periodScale else { return [] }
        
        let transactionsByDateGroups = transactions.groupByKey { $0.gotAt.dateAtStartOf(periodScale.asUnit) }
        
        let amountsByDate = transactionsByDateGroups.compactMapKeysAndValues { (date, transactionsByDate) -> (Date, String)? in
            
            guard let amount = amountForTransactions(transactionsByDate).moneyCurrencyString(with: currency, shouldRound: true) else { return nil }
            
            return (date, amount)
        }
        
        return dataPoints.compactMap { date -> String? in
            
            func emptyAmount() -> String? {
                return 0.moneyCurrencyString(with: currency, shouldRound: false)
            }
            
            return amountsByDate[date] ?? emptyAmount()
        }
    }
    
    func pieChartDatas(for transactions: [HistoryTransactionViewModel],
                       currency: Currency?,
                       periodScale: GraphPeriodScale?,
                       keyForTransaction: @escaping (HistoryTransactionViewModel) -> Int,
                       amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber,
                       titleForTransaction: @escaping (HistoryTransactionViewModel) -> String,
                       colorForTransaction: ((HistoryTransactionViewModel) -> UIColor?)? = nil) -> [PieChartData] {
        
        guard let periodScale = periodScale else { return [] }
        
        let transactionsByDateGroups = transactions.groupByKey { $0.gotAt.dateAtStartOf(periodScale.asUnit) }
        
        let dataChartsByDate = transactionsByDateGroups.compactMapKeysAndValues { (date, transactionsByDate) -> (Date, PieChartData)? in
            
            guard let chartData = pieChartData(for: date,
                                               transactions: transactionsByDate,
                                               currency: currency,
                                               periodScale: periodScale,
                                               keyForTransaction: keyForTransaction,
                                               amountForTransactions: amountForTransactions,
                                               titleForTransaction: titleForTransaction,
                                               colorForTransaction: colorForTransaction) else { return nil }
            return (date, chartData)
        }
        
        return dataPoints.compactMap { date -> PieChartData? in
            
            func emptyPieChartData() -> PieChartData? {
                let title = date.string(withFormat: periodScale.dateFormat)
                let dataSet = createPieDataSet(title: title)
                dataSet.addColor(.gray)
                _ = dataSet.addEntryOrdered(PieChartDataEntry(value: 1.0))
                let data = createPieChartData(with: dataSet,
                                              currency: currency)
                return data
            }
            
            
            
            
            return dataChartsByDate[date] ?? emptyPieChartData()
        }
    }
    
    private func pieChartData(for date: Date,
                              transactions: [HistoryTransactionViewModel],
                              currency: Currency?,
                              periodScale: GraphPeriodScale,
                              keyForTransaction: @escaping (HistoryTransactionViewModel) -> Int,
                              amountForTransactions: @escaping ([HistoryTransactionViewModel]) -> NSDecimalNumber,
                              titleForTransaction: @escaping (HistoryTransactionViewModel) -> String,
                              colorForTransaction: ((HistoryTransactionViewModel) -> UIColor?)? = nil) -> PieChartData? {
        
        guard let currency = currency else { return nil }
        
        let title = date.string(withFormat: periodScale.dateFormat)
        let dataSet = createPieDataSet(title: title)
        let amount = amountForTransactions(transactions)
        
        let transactionsByDateAndKeyGroups = transactions.groupByKey { keyForTransaction($0) }
        
        for transactionsByDateAndKeyGroup in transactionsByDateAndKeyGroups {
            
            let key = transactionsByDateAndKeyGroup.key
            let transactionsByDateAndKey = transactionsByDateAndKeyGroup.value
            
            let value = amountForTransactions(transactionsByDateAndKey)
            let percents = value.multiplying(byPowerOf10: 2).dividing(by: amount)
            
            if let transaction = transactionsByDateAndKey.first,
                case let title = percentsFormatter.string(from: percents) {
                
                let color = colorForTransaction?(transaction) ?? randomColor(hue: .random, luminosity: dataSet.values.count.isEven ? .dark : .light)
                dataSet.addColor(color)
                _ = dataSet.addEntryOrdered(PieChartDataEntry(value: value.doubleValue, label: title, data: key as AnyObject))
                
            }
            
        }
        
        return createPieChartData(with: dataSet, currency: currency)
    }
    
    private func createPieChartData(with dataSet: PieChartDataSet, currency: Currency?) -> PieChartData? {
        guard let currency = currency else { return nil }
        
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartData.setValueFormatter(CurrencyValueFormatter(currency: currency))
        return pieChartData
    }
    
    private func createPieDataSet(title: String) -> PieChartDataSet {
        let dataSet = PieChartDataSet(values: [], label: title)
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        dataSet.xValuePosition = .insideSlice
        dataSet.entryLabelFont  = UIFont(name: "Rubik-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        dataSet.entryLabelColor = .black
        dataSet.resetColors()
        return dataSet
    }
}
