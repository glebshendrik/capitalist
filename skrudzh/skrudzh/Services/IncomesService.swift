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
    func create(with creationForm: IncomeCreationForm) -> Promise<Income> {
        return request(APIResource.createIncome(form: creationForm))
    }
    
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateIncome(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyIncome(id: id))
    }
}
