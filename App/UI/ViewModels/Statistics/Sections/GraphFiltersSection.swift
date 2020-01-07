//
//  GraphFiltersSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class GraphFiltersSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return viewModel.graphFilters.count }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .graphFilters }
    
    private let viewModel: GraphViewModel
    
    init(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }
    
    func filterViewModel(at index: Int) -> GraphTransactionFilter? {
        return viewModel.graphFilters.item(at: index)
    }
}
