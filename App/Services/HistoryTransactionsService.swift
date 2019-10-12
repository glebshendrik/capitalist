//
//  HistoryTransactionsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class HistoryTransactionsService : Service, HistoryTransactionsServiceProtocol {
    func index(for userId: Int) -> Promise<[Transaction]> {
        return requestCollection(APIRoute.indexHistoryTransactions(userId: userId))
    }
}
