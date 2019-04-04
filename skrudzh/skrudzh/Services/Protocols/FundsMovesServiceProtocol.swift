//
//  FundsMovesServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol FundsMovesServiceProtocol {
    func create(with creationForm: FundsMoveCreationForm) -> Promise<FundsMove>
    func show(by id: Int) -> Promise<FundsMove>
    func update(with updatingForm: FundsMoveUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}
