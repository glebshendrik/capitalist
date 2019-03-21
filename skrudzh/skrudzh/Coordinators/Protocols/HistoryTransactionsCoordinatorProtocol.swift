//
//  HistoryTransactionsCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol HistoryTransactionsCoordinatorProtocol {
    func index() -> Promise<[HistoryTransaction]>
}
