//
//  GraphHistoryTransactionFilter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class GraphHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    let color: UIColor
    let currency: Currency
    
    var date: Date?
    var aggregationType: AggregationType?
    
    var aggregatedValues: [AggregationType : Double] = [:]
    var values: [Date : Double] = [:]
    
    var amount: Double? {
        guard let date = date else { return nil }
        return values[date]
    }
    
    var total: Double {
        return aggregatedValues[AggregationType.total] ?? aggregatedValues[AggregationType.minimum] ?? 0.0
    }
    
    var aggregated: Double? {
        guard let aggregationType = aggregationType else { return nil }
        return aggregatedValues[aggregationType]
    }
    
    init(id: Int, title: String, type: HistoryTransactionSourceOrDestinationType, color: UIColor, сurrency: Currency) {
        self.color = color
        self.currency = сurrency
        super.init(id: id, title: title, type: type)
    }
}
