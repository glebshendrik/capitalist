//
//  ExpenseCategoriesServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpenseCategoriesServiceProtocol {
    func create(with creationForm: ExpenseCategoryCreationForm) -> Promise<ExpenseCategory>
    func show(by id: Int) -> Promise<ExpenseCategory>
    func indexExpenseCategories(for basketId: Int) -> Promise<[ExpenseCategory]>
    func indexUserExpenseCategories(for userId: Int) -> Promise<[ExpenseCategory]>
    func update(with updatingForm: ExpenseCategoryUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: ExpenseCategoryPositionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
