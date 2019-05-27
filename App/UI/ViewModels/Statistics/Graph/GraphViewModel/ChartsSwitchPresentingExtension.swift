//
//  ChartsSwitchPresentingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    
    var linePieChartSwitchHidden: Bool {
        switch graphType {
        case .income, .incomePie, .expenses, .expensesPie:
            return false
        default:
            return true
        }
    }
    
    var linePieChartSwitchIconName: String? {
        switch graphType {
        case .income, .expenses:
            return "pie-chart-icon"
        case .incomePie, .expensesPie:
            return "line-chart-icon"
        default:
            return nil
        }
    }
    
    var lineChartHidden: Bool {
        switch graphType {
        case .incomePie, .expensesPie:
            return true
        default:
            return false
        }
    }
    
    var pieChartHidden: Bool {
        switch graphType {
        case .incomePie, .expensesPie:
            return false
        default:
            return true
        }
    }
    
    func switchLinePieChart() {
        
        func graphTypeForLinePieSwitch() -> GraphType {
            switch graphType {
            case .income:
                return .incomePie
            case .incomePie:
                return .income
            case .expenses:
                return .expensesPie
            case .expensesPie:
                return .expenses
            default:
                return graphType
            }
        }
        
        graphType = graphTypeForLinePieSwitch()
    }
}
