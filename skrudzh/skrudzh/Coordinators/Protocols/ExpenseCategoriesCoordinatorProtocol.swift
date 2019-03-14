//
//  ExpenseCategoriesCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpenseCategoriesCoordinatorProtocol {
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory>
    func show(by id: Int) -> Promise<ExpenseCategory>
    func index(for basketType: BasketType) -> Promise<[ExpenseCategory]>
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: ExpenseCategoryPositionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
