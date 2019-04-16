//
//  GraphHistoryTransactionFilter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class GraphHistoryTransactionFilter : SourceOrDestinationHistoryTransactionFilter {
    var сurrency: Currency?
    var amount: Double?
    var aggregated: Double?
    var aggregationType: AggregationType?
    var color: UIColor?
}
