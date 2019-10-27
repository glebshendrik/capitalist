//
//  ActivesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ActivesViewModel {
    private let activesCoordinator: ActivesCoordinatorProtocol
    private var activeViewModels: [ActiveViewModel] = []
    
    var numberOfActives: Int {
        return activeViewModels.count
    }
    
    var skipActiveId: Int? = nil
    
    init(activesCoordinator: ActivesCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
    }
    
    func loadActives() -> Promise<Void> {
        return  firstly {
                    activesCoordinator.indexUserActives()
                }.get { actives in
                    self.activeViewModels = actives
                        .map { ActiveViewModel(active: $0)}
                        .filter { $0.id != self.skipActiveId }
                }.asVoid()
    }
    
    func activeViewModel(at indexPath: IndexPath) -> ActiveViewModel? {
        return activeViewModels.item(at: indexPath.row)
    }
}
