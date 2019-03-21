//
//  HistoryTransactionsService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class HistoryTransactionsService : Service, HistoryTransactionsServiceProtocol {
    func index(for userId: Int) -> Promise<[HistoryTransaction]> {
        return requestCollection(APIResource.indexHistoryTransactions(userId: userId))
    }
}
