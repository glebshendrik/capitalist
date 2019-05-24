//
//  ExpenseSourcesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
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
    
    func index(for userId: Int, noDebts: Bool) -> Promise<[ExpenseSource]> {        
        return requestCollection(APIResource.indexExpenseSources(userId: userId, noDebts: noDebts))
    }
    
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpenseSource(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: ExpenseSourcePositionUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpenseSourcePosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIResource.destroyExpenseSource(id: id, deleteTransactions: deleteTransactions))
    }
    
    
}
