//
//  FiltersViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class FiltersViewModel {
    public private(set) var transactionableFilters: [TransactionableFilter] = []    
    
    var hasFilters: Bool {
        return numberOfTransactionableFilters > 0
    }
    
    var numberOfTransactionableFilters: Int {
        return transactionableFilters.count
    }
                            
    func set(transactionableFilters: [TransactionableFilter]) {
        self.transactionableFilters = transactionableFilters
    }
    
    func transactionableFilter(at indexPath: IndexPath) -> TransactionableFilter? {        
        return transactionableFilters[safe: indexPath.row]
    }
}
