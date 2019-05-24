//
//  WaitingDebtsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class WaitingDebtsViewModel {
    private var fundsMoveViewModels: [FundsMoveViewModel] = []
    
    var numberOfItems: Int {
        return fundsMoveViewModels.count
    }
    
    func set(fundsMoveViewModels: [FundsMoveViewModel]) {
        self.fundsMoveViewModels = fundsMoveViewModels
    }
    
    func fundsMoveViewModel(at indexPath: IndexPath) -> FundsMoveViewModel? {
        return fundsMoveViewModels.item(at: indexPath.row)
    }
}
