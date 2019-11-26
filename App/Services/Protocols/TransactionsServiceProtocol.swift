//
//  FundsMovesServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol TransactionsServiceProtocol {
    func index(for userId: Int,
               type: TransactionType?,
               transactionableId: Int?,
               transactionableType: TransactionableType?,
               creditId: Int?,
               borrowId: Int?,
               borrowType: BorrowType?,
               count: Int?,
               lastGotAt: Date?) -> Promise<[Transaction]>
    func create(with creationForm: TransactionCreationForm) -> Promise<Transaction>
    func show(by id: Int) -> Promise<Transaction>
    func update(with updatingForm: TransactionUpdatingForm) -> Promise<Void>
    func destroy(by id: Int) -> Promise<Void>
}
