//
//  ClearFiltersSection.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 19.11.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class ClearFiltersSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return 1 }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .clearFilters }    
}
