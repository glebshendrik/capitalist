//
//  IncomeGraphDataCalculatingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
                              fillDataSetAreas: true)
    }
    
    func calculateIncomePieChartDatas() -> [PieChartData] {
        return pieChartDatas(for: transactions,
                             currency: currency,
                             periodScale: graphPeriodScale,
                             keyForTransaction: { $0.sourceId },
                             amountForTransactions: { self.amount(for: $0) },
                             titleForTransaction: { $0.sourceTitle })
        
    }
    
    
    
}
