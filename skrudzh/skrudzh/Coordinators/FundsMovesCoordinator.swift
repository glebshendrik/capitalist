//
//  FundsMovesCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class FundsMovesCoordinator : FundsMovesCoordinatorProtocol {
    private let fundsMovesService: FundsMovesServiceProtocol
    
    init(fundsMovesService: FundsMovesServiceProtocol) {
        self.fundsMovesService = fundsMovesService
    }
    
    func create(with creationForm: FundsMoveCreationForm) -> Promise<FundsMove> {
        return fundsMovesService.create(with: creationForm)
    }
    
    func show(by id: Int) -> Promise<FundsMove> {
        return fundsMovesService.show(by: id)
    }
    
    func update(with updatingForm: FundsMoveUpdatingForm) -> Promise<Void> {
        return fundsMovesService.update(with: updatingForm)
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return fundsMovesService.destroy(by: id)
    }
}
