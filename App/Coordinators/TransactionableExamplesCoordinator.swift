//
//  TransactionableExamplesCoordinator.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionableExamplesCoordinator : TransactionableExamplesCoordinatorProtocol {
    private let transactionableExamplesService: TransactionableExamplesServiceProtocol
    
    init(transactionableExamplesService: TransactionableExamplesServiceProtocol) {
        self.transactionableExamplesService = transactionableExamplesService
    }
    
    func indexBy(_ transactioableType: TransactionableType, basketType: BasketType?, isUsed: Bool?) -> Promise<[TransactionableExample]> {
        return transactionableExamplesService.indexBy(transactioableType, basketType: basketType, isUsed: isUsed)
    }
}

