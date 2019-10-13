//
//  GraphViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

class GraphViewModel {
    let transactionsViewModel: TransactionsViewModel
    
    var graphType: GraphType = .incomeAndExpenses {
        didSet {
            guard graphType != oldValue else { return }
            updateChartsData()
            updateAggregationType()
            updateGraphFiltersVisibility()
        }
    }
    
    var aggregationType: AggregationType = .total {
        didSet {
            guard aggregationType != oldValue else { return }
            updateGraphFiltersAggregationType()
            updateAggregatedTotal()
        }
    }
    
    var graphPeriodScale: GraphPeriodScale? = nil {
        didSet {
            guard graphPeriodScale != oldValue else { return }
            updateChartsData()            
        }
    }
    
    var areGraphFiltersShown: Bool = true
    
    public private(set) var dataPoints: [Date] = [] {
        didSet {
            lineChartCurrentPoint = maxDataPoint
            pieChartsCollectionContentOffset = nil
        }
    }
    
    var lineChartCurrentPoint: Double? = nil {
        didSet {
            currentDate = lineChartCurrentPointDate
        }
    }
    var pieChartsCollectionContentOffset: CGPoint? = nil
    var currentPieChartIndex: Int? = nil {
        didSet {
            currentDate = pieChartCurrentPointDate
        }
    }
    
    var currentDate: Date? = nil {
        didSet {
            guard currentDate != oldValue else { return }
            updateGraphFiltersCurrentDate()
        }
    }
    
    public private(set) var lineChartData: LineChartData? = nil
    public private(set) var pieChartDatas: [PieChartData] = []
    public private(set) var pieChartsAmounts: [String] = []
    
    var graphFilters: [GraphTransactionFilter] = []
    var filtersAggregatedTotal: Double? = nil
    var filtersTotalByDate: [Date: Double] = [:]
    
    lazy var percentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = "%"
        return formatter
    }()
    
    init(transactionsViewModel: TransactionsViewModel) {
        self.transactionsViewModel = transactionsViewModel
    }
    
    func updateChartsData(with defaultPeriod: AccountingPeriod?) {
        func scalePeriod(by accountingPeriod: AccountingPeriod?) -> GraphPeriodScale? {
            guard let accountingPeriod = accountingPeriod else { return nil }
            switch accountingPeriod {
            case .week:
                return .weeks
            case .month:
                return .months
            case .quarter:
                return .quarters
            case .year:
                return .years
            }
        }
        graphPeriodScale = scalePeriod(by: defaultPeriod)
    }
    
    func updateChartsData() {
        updateDataPoints()
        
        lineChartData = nil
        pieChartDatas = []
        pieChartsAmounts = []
        
        switch graphType {
        case .income:
            lineChartData = calculateIncomeChartData()
        case .incomePie:
            pieChartDatas = calculateIncomePieChartDatas()
            pieChartsAmounts = calculateIncomePieChartsAmounts()
        case .expenses:
            lineChartData = calculateExpensesChartData()
        case .expensesPie:            
            pieChartDatas = calculateExpensesPieChartDatas()            
            pieChartsAmounts = calculateExpensePieChartsAmounts()
        case .incomeAndExpenses:
            lineChartData = calculateIncomeAndExpensesChartData()
        case .cashFlow:
            lineChartData = calculateCashFlowChartData()
        case .netWorth:
            lineChartData = calculateNetWorthChartData()
        }
        
        updateGraphFilters()
    }
    
    private func updateDataPoints() {
        guard let graphPeriodScale = graphPeriodScale else {
            dataPoints = []
            return
        }
        
        var range = datesRange(graphPeriodScale: graphPeriodScale,
                               from: transactions.last?.gotAt.dateAtStartOf(graphPeriodScale.asUnit),
                               to: transactions.first?.gotAt.dateAtStartOf(graphPeriodScale.asUnit))
        if  range.count == 1,
            pieChartHidden,
            let first = range.first,
            let date = Calendar.current.date(byAdding: graphPeriodScale.addingUnit, value: -graphPeriodScale.addingValue, to: first) {

            range.insert(date, at: 0)
        }
        
        dataPoints = range
    }
}
