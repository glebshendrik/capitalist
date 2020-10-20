//
//  TransactionableExamplesService.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionableExamplesService : Service, TransactionableExamplesServiceProtocol {
    func indexBy(_ transactioableType: TransactionableType, basketType: BasketType?, isUsed: Bool) -> Promise<[TransactionableExample]> {
        return requestCollection(APIRoute.indexTransactionableExamples(transactionableType: transactioableType, basketType: basketType, isUsed: isUsed))
    }
}
