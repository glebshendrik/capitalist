//
//  TransactionableExampleViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 22.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class TransactionableExampleViewModel {
    public private(set) var name: String
    public private(set)var iconURL: URL?
    public private(set)var defaultIconName: String
    public private(set)var description: String?
    public private(set)var prototypeKey: String?
    public private(set)var providerCodes: [String]?
    
    var selected: Bool = false
    
    init(example: TransactionableExample) {
        name = example.localizedName
        description = example.localizedDescription
        iconURL = example.iconURL
        defaultIconName = example.transactionableType.defaultIconName(basketType: example.basketType)
        prototypeKey = example.prototypeKey
        providerCodes = example.providerCodes
    }
    
    init(transactionable: Transactionable) {
        name = transactionable.name
        description = nil
        iconURL = transactionable.iconURL
        defaultIconName = transactionable.type.defaultIconName(basketType: (transactionable as? ExpenseCategoryViewModel)?.basketType)
        selected = true
        prototypeKey = transactionable.prototypeKey
        providerCodes = (transactionable as? ExpenseSourceViewModel)?.providerCodes
    }
}
