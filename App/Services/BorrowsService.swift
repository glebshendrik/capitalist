//
//  BorrowsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BorrowsService : Service, BorrowsServiceProtocol {
    func indexDebts(for userId: Int) -> Promise<[Borrow]> {
        return requestCollection(APIRoute.indexDebts(userId: userId))
    }
    
    func indexLoans(for userId: Int) -> Promise<[Borrow]> {
        return requestCollection(APIRoute.indexLoans(userId: userId))
    }
    
    func createDebt(with creationForm: BorrowCreationForm) -> Promise<Borrow> {
        return request(APIRoute.createDebt(form: creationForm))
    }
    
    func createLoan(with creationForm: BorrowCreationForm) -> Promise<Borrow> {
        return request(APIRoute.createLoan(form: creationForm))
    }
    
    func showDebt(by id: Int) -> Promise<Borrow> {
        return request(APIRoute.showDebt(id: id))
    }
    
    func showLoan(by id: Int) -> Promise<Borrow> {
        return request(APIRoute.showLoan(id: id))
    }
    
    func updateDebt(with updatingForm: BorrowUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateDebt(form: updatingForm))
    }
    
    func updateLoan(with updatingForm: BorrowUpdatingForm) -> Promise<Void> {
        return request(APIRoute.updateLoan(form: updatingForm))
    }
    
    func destroyDebt(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return request(APIRoute.destroyDebt(id: id, deleteTransactions: deleteTransactions))
    }
    
    func destroyLoan(by id: Int, deleteTransactions: Bool) -> Promise<Void> {        
        return request(APIRoute.destroyLoan(id: id, deleteTransactions: deleteTransactions))
    }
}
