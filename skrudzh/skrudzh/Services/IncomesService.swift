//
//  IncomesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class IncomesService : Service, IncomesServiceProtocol {
    func create(with creationForm: IncomeCreationForm, closeActive: Bool) -> Promise<Income> {
        return request(APIResource.createIncome(form: creationForm, shouldCloseActive: closeActive))
    }
    
    func show(by id: Int) -> Promise<Income> {
        return request(APIResource.showIncome(id: id))
    }
    
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateIncome(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyIncome(id: id))
    }
}
