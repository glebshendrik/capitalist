//
//  CreditsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CreditsService : Service, CreditsServiceProtocol {
    func indexCredits(for userId: Int) -> Promise<[Credit]> {
        return requestCollection(APIRoute.indexCredits(userId: userId))
    }
        
    func createCredit(with creationForm: CreditCreationForm) -> Promise<Credit> {
        return request(APIRoute.createCredit(form: creationForm))
    }
        
    func showCredit(by id: Int) -> Promise<Credit> {
        return request(APIRoute.showCredit(id: id))
    }
    
    func updateCredit(with updatingForm: CreditUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateCredit(form: updatingForm))
    }
    
    func destroyCredit(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyCredit(id: id, deleteTransactions: deleteTransactions))
    }
}
