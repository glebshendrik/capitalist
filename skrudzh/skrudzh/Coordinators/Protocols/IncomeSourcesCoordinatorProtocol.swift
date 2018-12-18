//
//  IncomeSourcesCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol IncomeSourcesCoordinatorProtocol {
    func create(with creationForm: IncomeSourceCreationForm) -> Promise<IncomeSource>
    func show(by id: Int) -> Promise<IncomeSource>
    func index() -> Promise<[IncomeSource]>
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}