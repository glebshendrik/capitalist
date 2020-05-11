//
//  TransactionsCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol TransactionsCoordinatorProtocol {
    func index(fromGotAt: Date?,
               toGotAt: Date?) -> Promise<[Transaction]>
    func index(transactionableId: Int?,
               transactionableType: TransactionableType?,
               creditId: Int?,
               borrowId: Int?,
               borrowType: BorrowType?,
               count: Int?,
               lastGotAt: Date?) -> Promise<[Transaction]>
    func index(by type: TransactionType) -> Promise<[Transaction]>
    func create(with creationForm: TransactionCreationForm) -> Promise<Transaction>
    func show(by id: Int) -> Promise<Transaction>
    func update(with updatingForm: TransactionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}
