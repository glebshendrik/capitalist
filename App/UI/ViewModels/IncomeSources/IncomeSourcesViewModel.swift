//
//  IncomeSourcesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IncomeSourcesViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    
    var numberOfIncomeSources: Int {
        return incomeSourceViewModels.count
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
    }
    
    func loadIncomeSources() -> Promise<Void> {
        return  firstly {
            incomeSourcesCoordinator.index(noBorrows: true)
        }.get { incomeSources in
            self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
        }.asVoid()
    }
    
    func incomeSourceViewModel(at indexPath: IndexPath) -> IncomeSourceViewModel? {
        return incomeSourceViewModels.item(at: indexPath.row)
    }
}
