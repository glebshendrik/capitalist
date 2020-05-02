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
    
    func calculatePieChartData(for filters: [GraphTransactionFilter], currency: Currency?) -> PieChartData? {
        guard let currency = currency else { return nil }
        
        guard filters.count > 0 else { return emptyPieChartData(currency: currency) }
                        
        let dataSet = createPieDataSet()
        
        for filter in filters {
            dataSet.addColor(filter.color)
            _ = dataSet.addEntryOrdered(PieChartDataEntry(value: filter.amount.doubleValue, label: nil, data: filter.key as AnyObject))
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
