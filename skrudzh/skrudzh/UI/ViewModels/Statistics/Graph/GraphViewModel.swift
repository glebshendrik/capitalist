//
//  GraphViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts
import RandomColorSwift
import SwifterSwift

class GraphViewModel {
    let historyTransactionsViewModel: HistoryTransactionsViewModel
    
    var graphType: GraphType = .incomeAndExpenses {
        didSet {
            updateChartsData()
        }
    }
    
    var graphPeriodScale: GraphPeriodScale = .days {
        didSet {
            updateChartsData()
        }
    }
    
    public private(set) var dataPoints: [Date] = [] {
        didSet {
            lineChartCurrentPoint = maxDataPoint
            pieChartsCollectionContentOffset = nil
        }
    }
    
    lazy var percentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = "%"
        return formatter
    }()
    
    var lineChartCurrentPoint: Double? = nil
    var pieChartsCollectionContentOffset: CGPoint? = nil
    
    public private(set) var lineChartData: LineChartData? = nil
    public private(set) var pieChartDatas: [PieChartData] = []
    public private(set) var pieChartsAmounts: [String] = []
    
    init(historyTransactionsViewModel: HistoryTransactionsViewModel) {
        self.historyTransactionsViewModel = historyTransactionsViewModel
    }
    
    func updateChartsData() {
        updateDataPoints()
        
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
    }
    
    private func updateDataPoints() {
        var range = datesRange(from: transactions.last?.gotAt.dateAtStartOf(graphPeriodScale.asUnit),
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
