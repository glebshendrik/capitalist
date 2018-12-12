//
//  MainViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class MainViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
    }
    
    func loadIncomeSources() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index()
                }.get { incomeSources in
                    self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                }.asVoid()
    }
}

class IncomeSourceViewModel {
    
    private let incomeSource: IncomeSource
    
    var id: Int {
        return incomeSource.id
    }
    
    var name: String {
        return incomeSource.name
    }
    
    var iconURL: URL? {
        return incomeSource.iconURL
    }
    
    init(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
    }
}
