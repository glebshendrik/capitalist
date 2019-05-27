//
//  IncomeGraphDataCalculatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift

extension GraphViewModel {
    
    func calculateIncomeChartData() -> LineChartData? {
        return lineChartData(for: transactions,
                              currency: currency,
                              periodScale: graphPeriodScale,
                              keyForTransaction: { $0.sourceId },
                              amountForTransactions: { self.amount(for: $0) },
                              titleForTransaction: { $0.sourceTitle },
                              accumulateValuesHistory: false,
                              accumulateValuesForDate: true,
                              fillDataSetAreas: true,
                              colorForTransaction: { self.color(for: $0) } )
    }
    
    func calculateIncomePieChartDatas() -> [PieChartData] {
        return pieChartDatas(for: transactions,
                             currency: currency,
                             periodScale: graphPeriodScale,
                             keyForTransaction: { $0.sourceId },
                             amountForTransactions: { self.amount(for: $0) },
                             titleForTransaction: { $0.sourceTitle },
                             colorForTransaction: { self.color(for: $0) })
        
    }
    
    func calculateIncomePieChartsAmounts() -> [String] {
        return pieChartsAmounts(for: transactions,
                                currency: currency,
                                periodScale: graphPeriodScale,
                                amountForTransactions: { self.amount(for: $0) })
    }
    
    func calculateIncomeFilters() -> [GraphHistoryTransactionFilter] {
        
        return calculateGraphFilters(for: transactions,
                                     currency: currency,
                                     periodScale: graphPeriodScale,
                                     keyForTransaction: { $0.sourceId },
                                     amountForTransactions: { self.amount(for: $0) },
                                     titleForTransaction: { $0.sourceTitle },
                                     accumulateValuesHistory: false,
                                     filterType: .incomeSource,
                                     colorForTransaction: { self.color(for: $0) })
    }
    
    private func color(for transaction: HistoryTransactionViewModel) -> UIColor? {
        guard let idIndex = incomeSourceIds.firstIndex(of: transaction.sourceId) else { return nil }
        return colors.item(at: idIndex)
    }
}
