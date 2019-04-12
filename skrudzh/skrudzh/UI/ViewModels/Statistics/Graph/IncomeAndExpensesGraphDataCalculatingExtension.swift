//
//  IncomeAndExpensesGraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    func incomeAndExpensesDataSetKey(by transactionableType: TransactionableType) -> Int {
        switch transactionableType {
        case .expense:      return 0
        case .income:       return 1
        case .fundsMove:    return 2
        }
    }
    
    func calculateIncomeAndExpensesChartData() -> LineChartData? {
        
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
        
        return lineChartData(for: transactions,
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
}
