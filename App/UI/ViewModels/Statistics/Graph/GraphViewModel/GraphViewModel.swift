//
//  GraphsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import UIKit
import Charts
import RandomColorSwift
import SwifterSwift

class GraphViewModel {
    let transactionsViewModel: TransactionsViewModel
    let periodsViewModel: PeriodsViewModel
    
    var currency: Currency? {
        return transactionsViewModel.defaultCurrency
    }
    
    var graphType: GraphType = .all {
        didSet {
            guard graphType != oldValue else { return }
            updateCurrentGraph()
        }
    }
                
    var numberOfGraphs: Int {
        return periodsViewModel.numberOfDateRanges
    }
                
    var total: String? = nil
    var subtitle: String? {
        guard let period = periodsViewModel.currentDateRangeFilterTitle else { return nil }
        switch graphType {
        case .all:
            return "Остаток на \(period)"
        case .incomes:
            return "Доход за \(period)"
        case .expenses:
            return "Расходы за \(period)"
        }
        
    }
    
    var dateRange: DateRangeTransactionFilter? {
        return periodsViewModel.currentDateRangeFilter
    }
    
    var pieChartData: PieChartData? = nil
    var emptyChartData: PieChartData? {
        return emptyPieChartData(currency: currency)
    }
    var graphFilters: [GraphTransactionFilter] = []
    
    var collectionContentOffset: CGPoint? = nil
    
    var currentChartIndex: Int {
        return periodsViewModel.currentDateRangeFilterIndex
    }
    
    var numberOfFilters: Int {
        return graphFilters.count
    }
    
    var hasData: Bool {
        guard let pieChartData = pieChartData else { return false }
        return pieChartData.entryCount > 0
    }
    
    var graphTypeIndex: Int {
        switch graphType {
        case .all:
            return 0
        case .incomes:
            return 1
        case .expenses:
            return 2
        }
    }
    
    init(transactionsViewModel: TransactionsViewModel,
         periodsViewModel: PeriodsViewModel) {
        self.transactionsViewModel = transactionsViewModel
        self.periodsViewModel = periodsViewModel
    }
    
    func setGraphType(by index: Int) {
        switch index {
        case 1:
            graphType = .incomes
        case 2:
            graphType = .expenses
        default:
            graphType = .all
        }
    }
    
    func set(chartIndex: Int) {
        periodsViewModel.currentDateRangeFilterIndex = chartIndex
    }
    
    func graphFilter(at index: Int) -> GraphTransactionFilter? {
        return graphFilters.item(at: index)
    }
    
    func updateCurrentGraph() {
        pieChartData = calculateChartData()
        graphFilters = calculateFilters()
        total = calculateTotal()        
    }
    
    func calculateChartData() -> PieChartData? {
        switch graphType {
        case .all:
            return calculateIncomeAndExpensesPieChartData()
        case .incomes:
            return calculateIncomePieChartData()
        case .expenses:
            return calculateExpensesPieChartData()
        }
    }
    
    func calculateFilters() -> [GraphTransactionFilter] {
        switch graphType {
        case .all:
            return calculateIncomeAndExpensesFilters()
        case .incomes:
            return calculateIncomeFilters()
        case .expenses:
            return calculateExpensesFilters()
        }
    }
    
    func calculateTotal() -> String? {
        switch graphType {
        case .all:
            return amount(for: incomes).subtracting(amount(for: expenses)).moneyCurrencyString(with: currency, shouldRound: true)
        default:
            return amount(for: transactions).moneyCurrencyString(with: currency, shouldRound: true)
        }
        
    }
}
