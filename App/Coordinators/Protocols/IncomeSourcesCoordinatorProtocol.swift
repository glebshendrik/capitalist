//
//  IncomeSourcesCoordinatorProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol IncomeSourcesCoordinatorProtocol {
    func create(with creationForm: IncomeSourceCreationForm) -> Promise<IncomeSource>
    func show(by id: Int) -> Promise<IncomeSource>
    func first(noBorrows: Bool) -> Promise<IncomeSource?>
    func firstBorrow(currency: String) -> Promise<IncomeSource>
    func index(noBorrows: Bool) -> Promise<[IncomeSource]>    
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
