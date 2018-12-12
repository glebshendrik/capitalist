//
//  IncomeSourcesService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
    
    func destroy(by id: Int) -> Promise<Void> {
        return request(APIResource.destroyIncomeSource(id: id))
    }
    
    
}
