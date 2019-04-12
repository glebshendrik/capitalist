//
//  ExpensesGraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    
    func calculateExpensesChartData() -> LineChartData? {
        return lineChartData(for: transactions,
                              currency: currency,
                              periodScale: graphPeriodScale,
                              keyForTransaction: { $0.destinationId },
                              amountForTransactions: { self.amount(for: $0) },
                              titleForTransaction: { $0.destinationTitle },
                              accumulateValuesHistory: false,
                              accumulateValuesForDate: true,
                              fillDataSetAreas: true)
    }
    
    func calculateExpensesPieChartDatas() -> [PieChartData] {
        return pieChartDatas(for: transactions,
                             currency: currency,
                             periodScale: graphPeriodScale,
                             keyForTransaction: { $0.destinationId },
                             amountForTransactions: { self.amount(for: $0) },
                             titleForTransaction: { $0.destinationTitle })
        
    }
}
