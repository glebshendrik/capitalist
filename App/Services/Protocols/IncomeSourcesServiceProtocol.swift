//
//  IncomeSourcesServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol IncomeSourcesServiceProtocol {
    func create(with creationForm: IncomeSourceCreationForm) -> Promise<IncomeSource>
    func show(by id: Int) -> Promise<IncomeSource>
    func firstBorrow(for userId: Int, currency: String) -> Promise<IncomeSource>
    func index(for userId: Int, noBorrows: Bool) -> Promise<[IncomeSource]>
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
