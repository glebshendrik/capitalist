//
//  PieChartPresentingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

extension GraphViewModel {
    
    
//    func pieChartAmount(for transactions: [TransactionViewModel],
//                        currency: Currency?,
//                        amountForTransactions: @escaping ([TransactionViewModel]) -> NSDecimalNumber) -> String? {
//
//        return amountForTransactions(transactions).moneyCurrencyString(with: currency, shouldRound: true)
//    }
    
    func calculatePieChartData(for transactions: [TransactionViewModel],
                               currency: Currency?,
                               keyForTransaction: @escaping (TransactionViewModel) -> String,
                               amountForTransactions: @escaping ([TransactionViewModel]) -> NSDecimalNumber,
                               titleForTransaction: @escaping (TransactionViewModel) -> String,
                               colorForTransaction: ((TransactionViewModel) -> UIColor?)? = nil) -> PieChartData? {
        
        guard let currency = currency else { return nil }
        
        let dataSet = createPieDataSet()
//        let amount = amountForTransactions(transactions)
        
        let transactionsByKeyGroups = transactions.groupByKey { keyForTransaction($0) }
        
        guard transactionsByKeyGroups.count > 0 else { return emptyPieChartData(currency: currency) }
        
        for transactionsByKeyGroup in transactionsByKeyGroups {
            
            let key = transactionsByKeyGroup.key
            let transactionsByKey = transactionsByKeyGroup.value
            
            let value = amountForTransactions(transactionsByKey)
//            let percents = value.multiplying(byPowerOf10: 2).dividing(by: amount)
            
            if let transaction = transactionsByKey.first {
                
                let color = colorForTransaction?(transaction) ?? randomColor(hue: .random, luminosity: dataSet.values.count.isEven ? .dark : .light)
                dataSet.addColor(color)
                _ = dataSet.addEntryOrdered(PieChartDataEntry(value: value.doubleValue, label: nil, data: key as AnyObject))
                
            }
            
        }
        
        return createPieChartData(with: dataSet, currency: currency)
    }
    
    func emptyPieChartData(currency: Currency?) -> PieChartData? {
        let dataSet = createPieDataSet()
        dataSet.addColor(UIColor.by(.gray1))
        _ = dataSet.addEntryOrdered(PieChartDataEntry(value: 1.0))
        let data = createPieChartData(with: dataSet,
                                      currency: currency)
        return data
    }
    
    private func createPieChartData(with dataSet: PieChartDataSet, currency: Currency?) -> PieChartData? {
        guard let currency = currency else { return nil }
        
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartData.setValueFormatter(CurrencyValueFormatter(currency: currency))
        return pieChartData
    }
    
    private func createPieDataSet() -> PieChartDataSet {
        let dataSet = PieChartDataSet(values: [], label: nil)
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        dataSet.xValuePosition = .insideSlice
        dataSet.entryLabelFont  = UIFont(name: "Roboto-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        dataSet.entryLabelColor = .black
        dataSet.resetColors()
        return dataSet
    }
}
