//
//  IncomesServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol IncomesServiceProtocol {
    func create(with creationForm: IncomeCreationForm, closeActive: Bool) -> Promise<Income>
    func show(by id: Int) -> Promise<Income>
    func update(with updatingForm: IncomeUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}
