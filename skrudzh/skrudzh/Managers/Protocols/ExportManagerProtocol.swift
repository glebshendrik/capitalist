//
//  ExportManagerProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 23/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExportManagerProtocol {
    func export(transactions: [HistoryTransactionViewModel]) -> Promise<URL>    
}
