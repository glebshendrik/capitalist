//
//  ExpensesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpensesService : Service, ExpensesServiceProtocol {
    func create(with creationForm: ExpenseCreationForm) -> Promise<Expense> {
        return request(APIResource.createExpense(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<Expense> {
        return request(APIResource.showExpense(id: id))
    }
    
    func update(with updatingForm: ExpenseUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateExpense(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyExpense(id: id))
    }
}
