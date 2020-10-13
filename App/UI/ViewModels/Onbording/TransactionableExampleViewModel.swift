//
//  TransactionableExampleViewModel.swift
//  Three Baskets
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
    
    var selected: Bool = false
    
    init(example: TransactionableExample) {
        name = example.localizedName
        description = example.localizedDescription
        iconURL = example.iconURL
        defaultIconName = example.transactionableType.defaultIconName(basketType: example.basketType)
    }
    
    init(transactionable: Transactionable) {
        name = transactionable.name
        description = nil
        iconURL = transactionable.iconURL
        defaultIconName = transactionable.type.defaultIconName(basketType: (transactionable as? ExpenseCategoryViewModel)?.basketType)
        selected = true
    }
}
