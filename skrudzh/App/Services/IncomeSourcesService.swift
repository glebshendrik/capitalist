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
        return request(APIResource.createIncomeSource(form: creationForm))
    }
    
    func show(by id: Int) -> Promise<IncomeSource> {
        return request(APIResource.showIncomeSource(id: id))
    }
    
    func index(for userId: Int) -> Promise<[IncomeSource]> {
        return requestCollection(APIResource.indexIncomeSources(userId: userId))
    }
    
    func update(with updatingForm: IncomeSourceUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateIncomeSource(form: updatingForm))
    }
    
    func updatePosition(with updatingForm: IncomeSourcePositionUpdatingForm) -> Promise<Void> {
        return request(APIResource.updateIncomeSourcePosition(form: updatingForm))
    }
    
    func destroy(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIResource.destroyIncomeSource(id: id, deleteTransactions: deleteTransactions))
    }
    
    
}
