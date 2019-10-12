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
                             keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.transactionableType) },
                             amountForTransactions: { self.amount(for: $0) },
                             titleForTransaction: { self.title(by: $0.transactionableType) },
                             accumulateValuesHistory: false,
                             accumulateValuesForDate: false,
                             fillDataSetAreas: false,
                             colorForTransaction: { self.color(by: $0.transactionableType) })
    }
    
    func calculateIncomeAndExpensesFilters() -> [GraphHistoryTransactionFilter] {
        
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     periodScale: graphPeriodScale,
                                     keyForTransaction: { self.incomeAndExpensesDataSetKey(by: $0.transactionableType) },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { self.title(by: $0.transactionableType) },
                                     accumulateValuesHistory: false,
                                     filterType: .incomeSource,
                                     colorForTransaction: { self.color(by: $0.transactionableType) })
    }
    
    func transactionableType(by incomeAndExpensesKey: Int) -> TransactionType {
        switch incomeAndExpensesKey {
        case 0:     return .expense
        case 1:     return .income
        default:    return .fundsMove
        }
    }
    
    func incomeAndExpensesDataSetKey(by transactionableType: TransactionType) -> Int {
        switch transactionableType {
        case .expense:      return 0
        case .income:       return 1
        case .fundsMove:    return 2
        }
    }
    
    func transactionableTypeBy(incomeAndExpensesDataSetKey: Int) -> TransactionType? {
        switch incomeAndExpensesDataSetKey {
        case 0:         return .expense
        case 1:         return .income
        default:        return nil
        }
    }
    
    private func title(by transactionableType: TransactionType) -> String {
        switch transactionableType {
        case .expense:      return "Расходы"
        case .income:       return "Доход"
        case .fundsMove:    return "Переводы"
        }
    }
    
    private func color(by transactionableType: TransactionType) -> UIColor {
        switch transactionableType {
        case .expense:      return .red
        case .income:       return Color.Material.green
        case .fundsMove:    return .blue
        }
    }
}
