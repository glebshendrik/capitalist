//
//  ExportManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExportManagerProtocol {
    func export(transactions: [TransactionViewModel]) -> Promise<URL>    
}
