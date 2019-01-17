//
//  ExpenseSourcesServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExpenseSourcesServiceProtocol {
    func create(with creationForm: ExpenseSourceCreationForm) -> Promise<ExpenseSource>
    func show(by id: Int) -> Promise<ExpenseSource>
    func index(for userId: Int) -> Promise<[ExpenseSource]>
    func update(with updatingForm: ExpenseSourceUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}