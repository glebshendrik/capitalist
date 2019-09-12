//
//  FundsMovesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class FundsMovesService : Service, FundsMovesServiceProtocol {
    func create(with creationForm: FundsMoveCreationForm) -> Promise<FundsMove> {
        return request(APIRoute.createFundsMove(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<FundsMove> {
        return request(APIRoute.showFundsMove(id: id))
    }
    
    func update(with updatingForm: FundsMoveUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateFundsMove(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIRoute.destroyFundsMove(id: id))
    }
}
