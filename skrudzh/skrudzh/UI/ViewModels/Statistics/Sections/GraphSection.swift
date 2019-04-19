//
//  GraphSection.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

class GraphSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .graph }        
}
