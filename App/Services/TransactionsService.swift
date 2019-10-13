//
//  FundsMovesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionsService : Service, TransactionsServiceProtocol {
    func index(for userId: Int, type: TransactionType?) -> Promise<[Transaction]> {
        return requestCollection(APIRoute.indexTransactions(userId: userId, type: type))
    }
    
    func create(with creationForm: TransactionCreationForm) -> Promise<Transaction> {
        return request(APIRoute.createTransaction(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<Transaction> {
        return request(APIRoute.showTransaction(id: id))
    }
    
    func update(with updatingForm: TransactionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateTransaction(form: updatingForm))
    }
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIRoute.destroyTransaction(id: id))
    }
}
