//
//  ExpensesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpensesCoordinatorProtocol {
    func create(with creationForm: ExpenseCreationForm) -> Promise<Expense>
    func show(by id: Int) -> Promise<Expense>
    func update(with updatingForm: ExpenseUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}
