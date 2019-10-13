//
//  IncomeAndExpensesGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import SwifterSwift

extension GraphViewModel {
    
    func calculateIncomeAndExpensesChartData() -> LineChartData? {

        return lineChartData(for: transactions,
                             currency: currency,
                             periodScale: graphPeriodScale,
                             keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.type) },
                             amountForTransactions: { self.amount(for: $0) },
                             titleForTransaction: { self.title(by: $0.type) },
                             accumulateValuesHistory: false,
                             accumulateValuesForDate: false,
                             fillDataSetAreas: false,
                             colorForTransaction: { self.color(by: $0.type) })
    }
    
    func calculateIncomeAndExpensesFilters() -> [GraphTransactionFilter] {
        
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     periodScale: graphPeriodScale,
                                     keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.type) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(by: $0.type) },
                                     accumulateValuesHistory: false,
                                     filterType: .incomeSource,
                                     colorForTransaction: { self.color(by: $0.type) })
    }
    
    func type(by incomeAndExpensesKey: Int) -> TransactionType {
        switch incomeAndExpensesKey {
        case 0:     return .expense
        case 1:     return .income
        default:    return .fundsMove
        }
    }
    
    func incomeAndExpensesDataSetKey(by type: TransactionType) -> Int {
        switch type {
        case .expense:      return 0
        case .income:       return 1
        case .fundsMove:    return 2
        }
    }
    
    func typeBy(incomeAndExpensesDataSetKey: Int) -> TransactionType? {
        switch incomeAndExpensesDataSetKey {
        case 0:         return .expense
        case 1:         return .income
        default:        return nil
        }
    }
    
    private func title(by type: TransactionType) -> String {
        switch type {
        case .expense:      return "Расходы"
        case .income:       return "Доход"
        case .fundsMove:    return "Переводы"
        }
    }
    
    private func color(by type: TransactionType) -> UIColor {
        switch type {
        case .expense:      return .red
        case .income:       return Color.Material.green
        case .fundsMove:    return .blue
        }
    }
}
