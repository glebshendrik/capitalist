//
//  Transactionable.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 22/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

protocol Transactionable : class {
    var id: Int { get }
    var type: TransactionableType { get }
    var name: String { get }
    var iconURL: URL? { get }
    var iconCategory: IconCategory? { get }
    var currency: Currency { get }
    var amountRounded: String { get }
    var amount: String { get }
    var amountCents: Int { get }
    var isDeleted: Bool { get }
    var isSelected: Bool { get set }
    var defaultIconName: String { get }
    var prototypeKey: String? { get }
    var isVirtual: Bool { get }
}

extension Transactionable {
    var defaultIconName: String {
        return type.defaultIconName
    }
}

protocol TransactionSource : Transactionable {
    var isTransactionSource: Bool { get }
}

protocol TransactionDestination : Transactionable {
    func isTransactionDestinationFor(transactionSource: TransactionSource) -> Bool
}

enum TransactionPart {
    case source, destination
}
