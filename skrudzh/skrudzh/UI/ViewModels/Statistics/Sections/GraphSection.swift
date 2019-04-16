//
//  GraphSection.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

enum GraphCellType {
    case graph
    case filtersToggle
    case filter
    case total
    
    var identifier: String {
        switch self {
        case .graph:
            return "GraphTableViewCell"
        case .filtersToggle:
            return "GraphFiltersToggleTableViewCell"
        case .filter:
            return "GraphFilterTableViewCell"
        case .total:
            return "GraphTotalTableViewCell"
        }
    }
}

class GraphSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return cellTypes.count }
    var title: String? { return nil }
    
    let viewModel: GraphViewModel
    
    private var cellTypes: [GraphCellType] {
        var types: [GraphCellType] = []
        
        types.append(.graph)
        
        if viewModel.shouldShowFiltersToggle {
            types.append(.filtersToggle)
        }
        
        if viewModel.areGraphFiltersShown {
            types.append(contentsOf: viewModel.graphFilters.map { _ in GraphCellType.filter })
        }
        
        if viewModel.shouldShowTotal {
            types.append(.total)
        }
        
        return types
    }
    
    init(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }
    
    func cellType(at indexPath: IndexPath) -> GraphCellType? {
        return cellTypes.item(at: indexPath.row)
    }
}
