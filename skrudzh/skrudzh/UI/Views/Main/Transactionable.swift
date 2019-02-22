//
//  Transactionable.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

protocol TransactionStartable {
    var canStartTransaction: Bool { get }
}

protocol TransactionCompletable {
    func canComplete(startable: TransactionStartable) -> Bool
}

typealias Transactionable = TransactionStartable & TransactionCompletable
