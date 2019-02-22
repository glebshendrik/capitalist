//
//  IncomesCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol IncomesCoordinatorProtocol {
    func create(with creationForm: IncomeCreationForm) -> Promise<Income>
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}