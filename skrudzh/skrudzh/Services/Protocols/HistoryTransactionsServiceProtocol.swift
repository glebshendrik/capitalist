//
//  HistoryTransactionsServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol HistoryTransactionsServiceProtocol {
    func index(for userId: Int) -> Promise<[HistoryTransaction]>
}

