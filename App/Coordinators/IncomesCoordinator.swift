//
//  IncomesCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IncomesCoordinator : IncomesCoordinatorProtocol {
    private let incomesService: IncomesServiceProtocol
    
    init(incomesService: IncomesServiceProtocol) {
        self.incomesService = incomesService
    }
    
    func create(with creationForm: IncomeCreationForm, closeActive: Bool) -> Promise<Income> {
        return incomesService.create(with: creationForm, closeActive: closeActive)
    }
    
    func show(by id: Int) -> Promise<Income> {
        return incomesService.show(by: id)
    }
    
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void> {
        return incomesService.update(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return incomesService.destroy(by: id)
    }
}
