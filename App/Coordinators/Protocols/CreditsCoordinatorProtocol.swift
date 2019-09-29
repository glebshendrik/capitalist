//
//  CreditsCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol CreditsCoordinatorProtocol {
    func indexCreditTypes() -> Promise<[CreditType]>
    func indexCredits() -> Promise<[Credit]>
    func createCredit(with creationForm: CreditCreationForm) -> Promise<Credit>
    func showCredit(by id: Int) -> Promise<Credit>
    func updateCredit(with updatingForm: CreditUpdatingForm) -> Promise<Void>
    func destroyCredit(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
