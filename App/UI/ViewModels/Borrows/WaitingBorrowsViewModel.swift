//
//  WaitingDebtsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class WaitingBorrowsViewModel {
    private var borrowViewModels: [BorrowViewModel] = []
    
    var numberOfItems: Int {
        return borrowViewModels.count
    }
    
    func set(borrowViewModels: [BorrowViewModel]) {
        self.borrowViewModels = borrowViewModels
    }
    
    func borrowViewModel(at indexPath: IndexPath) -> BorrowViewModel? {        
        return borrowViewModels[safe: indexPath.row]
    }
}
