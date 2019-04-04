//
//  FundsMovesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class FundsMovesService : Service, FundsMovesServiceProtocol {
    func create(with creationForm: FundsMoveCreationForm) -> Promise<FundsMove> {
        return request(APIResource.createFundsMove(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<FundsMove> {
        return request(APIResource.showFundsMove(id: id))
    }
    
    func update(with updatingForm: FundsMoveUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateFundsMove(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyFundsMove(id: id))
    }
}
