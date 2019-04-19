//
//  GraphFiltersSection.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 19/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

enum GraphFiltersSectionCellType {
    case filtersToggle
    case filter
    case total
    
    var identifier: String {
        switch self {
        case .filtersToggle:
            return "GraphFiltersToggleTableViewCell"
        case .filter:
            return "GraphFilterTableViewCell"
        case .total:
            return "GraphTotalTableViewCell"
        }
    }
}

class GraphFiltersSection : StatisticsViewSection {
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return cellTypes.count }
    var title: String? { return nil }
    var type: StatisticsViewSectionType { return .graphFilters }
    
    private let viewModel: GraphViewModel
    private var cellTypes: [GraphFiltersSectionCellType] = []
    
    init(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }
    
    func updateRows() {
        cellTypes = []
        
        if viewModel.shouldShowFiltersToggle {
            cellTypes.append(.filtersToggle)
        }
        
        if viewModel.areGraphFiltersShown {
            cellTypes.append(contentsOf: viewModel.graphFilters.map { _ in GraphFiltersSectionCellType.filter })
        }
        
        if viewModel.shouldShowTotal {
            cellTypes.append(.total)
        }
    }
    
    func cellType(at indexPath: IndexPath) -> GraphFiltersSectionCellType? {
        return cellTypes.item(at: indexPath.item)
    }
    
    func filterIndex(fromSectionIndexPath indexPath: IndexPath) -> Int {
        guard let firstFilterIndex = cellTypes.firstIndex(of: .filter) else { return indexPath.row }
        let index = indexPath.row - firstFilterIndex
        return index >= 0 ? index : 0
    }
}
