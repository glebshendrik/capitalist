//
//  HistoryTransactionsCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol HistoryTransactionsCoordinatorProtocol {
    func index() -> Promise<[HistoryTransaction]>
}
