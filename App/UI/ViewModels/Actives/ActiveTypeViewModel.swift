//
//  ActiveTypeViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class ActiveTypeViewModel {
    public private(set) var activeType: ActiveType
    
    var id: Int {
        return activeType.id
    }
        
    var name: String {
        return activeType.localizedName
    }
    
    var defaultPlannedIncomeType: ActiveIncomeType? {
        return activeType.defaultPlannedIncomeType
    }
    
    var isGoalAmountRequired: Bool {
        return activeType.isGoalAmountRequired
    }
    
    var isIncomePlannedDefault: Bool {
        return activeType.isIncomePlannedDefault
    }
        
    var rowOrder: Int {
        return activeType.rowOrder
    }
    
    var deletedAt: Date? {
        return activeType.deletedAt
    }
    
    init(activeType: ActiveType) {
        self.activeType = activeType
    }
}
