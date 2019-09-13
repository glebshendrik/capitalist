//
//  ExpenseSourcesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpenseSourcesCoordinatorProtocol {
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource>
    func show(by id: Int) -> Promise<ExpenseSource>
    func first(accountType: AccountType, currency: String) -> Promise<ExpenseSource>
    func index(noDebts: Bool, currency: String?) -> Promise<[ExpenseSource]>
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: ExpenseSourcePositionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
