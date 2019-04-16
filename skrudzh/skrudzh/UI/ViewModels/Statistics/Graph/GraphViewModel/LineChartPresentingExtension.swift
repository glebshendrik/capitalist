//
//  GraphDataPresentingAttributesExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import Charts

extension GraphViewModel {
    
    var minDataPoint: Double? {
        guard let date = dataPoints.first else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var maxDataPoint: Double? {
        guard let date = dataPoints.last else { return nil }
        return Double(date.timeIntervalSince1970)
    }
    
    var lineChartCurrentPointDate: Date? {
        guard let point = lineChartCurrentPoint else { return nil }
        return Date(timeIntervalSince1970: point)
    }
    
    var lineChartCurrentPointWithOffset: Double? {
        guard let point = lineChartCurrentPoint else { return nil }
        return point - visibleXRangeMaximum / 2.0
    }
    
    var isLineChartCurrentPositionMarkerHidden: Bool {
        return lineChartHidden || !hasData
    }
    
    var granularity: Double {
        guard numberOfDataPoints > 1 else { return 1.0 }
        return (dataPoints[1].timeIntervalSince1970 - dataPoints[0].timeIntervalSince1970)
    }
    
    var labelsCount: Int {
        return numberOfDataPoints < 5 ? numberOfDataPoints : 5
    }
    
    var visibleXRangeMaximum: Double {
        guard numberOfDataPoints > 1 else { return 1.0 }
        return Double(labelsCount - 1) * granularity
    }
    
    var shouldLimitMinimumValueToZero: Bool {
        switch graphType {
        case .income,
             .expenses,
             .incomeAndExpenses:
            return true
        default:
            return false
        }
    }    
}
