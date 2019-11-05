//
//  IncomeSourcesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IncomeSourcesService : Service, IncomeSourcesServiceProtocol {
    func create(with creationForm: IncomeSourceCreationForm) -> Promise<IncomeSource> {
        return request(APIRoute.createIncomeSource(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<IncomeSource> {
        return request(APIRoute.showIncomeSource(id: id))
    }
    
    func firstBorrow(for userId: Int, currency: String) -> Promise<IncomeSource> {
        return request(APIRoute.firstBorrowIncomeSource(userId: userId, currency: currency))
    }
    
    func index(for userId: Int, noBorrows: Bool) -> Promise<[IncomeSource]> {
        return requestCollection(APIRoute.indexIncomeSources(userId: userId, noBorrows: noBorrows))
    }
    
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateIncomeSource(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateIncomeSourcePosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyIncomeSource(id: id, deleteTransactions: deleteTransactions))
    }
    
    
}
