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
        return request(APIRoute.createExpenseSource(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<ExpenseSource> {
        return request(APIRoute.showExpenseSource(id: id))
    }
    
    func first(for userId: Int, accountType: AccountType, currency: String) -> Promise<ExpenseSource> {
        return request(APIRoute.firstExpenseSource(userId: userId, accountType: accountType, currency: currency))
    }
    
    func index(for userId: Int, noDebts: Bool, accountType: AccountType?, currency: String?) -> Promise<[ExpenseSource]> {
        return requestCollection(APIRoute.indexExpenseSources(userId: userId, noDebts: noDebts, accountType: accountType, currency: currency))
    }
    
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateExpenseSource(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: ExpenseSourcePositionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateExpenseSourcePosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyExpenseSource(id: id, deleteTransactions: deleteTransactions))
    }
    
    
}
