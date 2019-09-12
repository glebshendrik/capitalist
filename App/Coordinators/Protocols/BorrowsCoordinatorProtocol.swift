//
//  BorrowsCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol BorrowsCoordinatorProtocol {
    func indexDebts() -> Promise<[Borrow]>
    func indexLoans() -> Promise<[Borrow]>
    func createDebt(with creationForm: BorrowCreationForm) -> Promise<Borrow>
    func createLoan(with creationForm: BorrowCreationForm) -> Promise<Borrow>
    func showDebt(by id: Int) -> Promise<Borrow>
    func showLoan(by id: Int) -> Promise<Borrow>
    func updateDebt(with updatingForm: BorrowUpdatingForm) -> Promise<Void>
    func updateLoan(with updatingForm: BorrowUpdatingForm) -> Promise<Void>
    func destroyDebt(by id: Int, deleteTransactions: Bool) -> Promise<Void>
    func destroyLoan(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
