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
    func index(for userId: Int,
               type: TransactionType?,
               transactionableId: Int?,
               transactionableType: TransactionableType?,
               creditId: Int?,
               borrowId: Int?,
               borrowType: BorrowType?,
               count: Int?,
               lastGotAt: Date?) -> Promise<[Transaction]> {
        
        return requestCollection(APIRoute.indexTransactions(userId: userId,
                                                            type: type,
                                                            transactionableId: transactionableId,
                                                            transactionableType: transactionableType,
                                                            creditId: creditId,
                                                            borrowId: borrowId,
                                                            borrowType: borrowType,
                                                            count: count,
                                                            lastGotAt: lastGotAt))
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
