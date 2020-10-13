//
//  ExpenseSourcesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import Swinject

protocol ExpenseSourcesCoordinatorProtocol {
    func initDependencies(with resolver: Swinject.Resolver)
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource>
    func show(by id: Int) -> Promise<ExpenseSource>
    func syncedWithConnection(expenseSource: ExpenseSource) -> Promise<ExpenseSource>
    func refreshConnection(expenseSource: ExpenseSource) -> Promise<Void>
    func first() -> Promise<ExpenseSource?>
    func first(currency: String, isVirtual: Bool) -> Promise<ExpenseSource>
    func index(currency: String?) -> Promise<[ExpenseSource]>
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: ExpenseSourcePositionUpdatingForm) -> Promise<Void>
    func updateMaxFetchInterval(with updatingForm: ExpenseSourceMaxFetchIntervalUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
