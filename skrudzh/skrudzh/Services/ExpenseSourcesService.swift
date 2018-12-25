//
//  ExpenseSourcesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseSourcesService : Service, ExpenseSourcesServiceProtocol {
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource> {
        return request(APIResource.createExpenseSource(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<ExpenseSource> {
        return request(APIResource.showExpenseSource(id: id))
    }
    
    func index(for userId: Int) -> Promise<[ExpenseSource]> {
        return requestCollection(APIResource.indexExpenseSources(userId: userId))
    }
    
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpenseSource(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyExpenseSource(id: id))
    }
    
    
}
