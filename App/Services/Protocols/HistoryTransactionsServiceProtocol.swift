//
//  HistoryTransactionsServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol HistoryTransactionsServiceProtocol {
    func index(for userId: Int) -> Promise<[Transaction]>
}

