//
//  NetWorthGraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    func calculateNetWorthChartData() -> LineChartData? {
        guard let lineChartData = calculateIncomeAndExpensesChartData() else { return nil }
        
        let profitKey: Int = 0
        let capitalKey: Int = 1
        
        let identifiedDataSets : [IdentifiedLineChartDataSet] = lineChartData.dataSets.compactMap { $0 as? IdentifiedLineChartDataSet }
        
        guard   let expensesDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .expense) }),
            let incomeDataSet = identifiedDataSets.first(where: { $0.key == incomeAndExpensesDataSetKey(by: .income) }) else { return nil }
        
        let profitDataSet = createLineChartDataSet(key: profitKey, title: "Чистый доход", shouldFill: false, color: Color.Material.green)
        let capitalDataSet = createLineChartDataSet(key: capitalKey, title: "Капитал", shouldFill: false, color: Color.Material.blue)
        
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
}

