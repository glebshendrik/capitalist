//
//  TransactionableExampleViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class TransactionableExampleViewModel {
    private let example: TransactionableExample
    
    var selected: Bool = false
    
    var name: String {
        return example.localizedName
    }
    
    var iconURL: URL? {
        return example.iconURL
    }
    
    var defaultIconName: String {
        return example.transactionableType.defaultIconName(basketType: example.basketType)
    }
    
    init(example: TransactionableExample) {
        self.example = example
    }
}
