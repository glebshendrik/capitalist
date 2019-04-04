//
//  Transactionable.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 22/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation

protocol Transactionable {
    var id: Int { get }
    var name: String { get }
    var iconURL: URL? { get }
    var currency: Currency { get }
    var amountRounded: String { get }
    var amount: String { get }
}

protocol TransactionStartable : Transactionable {
    var canStartTransaction: Bool { get }
}

protocol TransactionCompletable : Transactionable {
    func canComplete(startable: TransactionStartable) -> Bool
}


