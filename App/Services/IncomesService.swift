//
//  IncomesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IncomesService : Service, IncomesServiceProtocol {
    func create(with creationForm: IncomeCreationForm, closeActive: Bool) -> Promise<Income> {
        return request(APIRoute.createIncome(form: creationForm, shouldCloseActive: closeActive))
    }
    
    func show(by id: Int) -> Promise<Income> {
        return request(APIRoute.showIncome(id: id))
    }
    
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateIncome(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIRoute.destroyIncome(id: id))
    }
}
