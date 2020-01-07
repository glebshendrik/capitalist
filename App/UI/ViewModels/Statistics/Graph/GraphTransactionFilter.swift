//
//  GraphTransactionFilter.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

enum GraphTransactionFilterSortingType {
    case id
    case percents
}

enum GraphTransactionFilterColoringType {
    case icon
    case progress
}

class GraphTransactionFilter : TransactionableFilter {
    let color: UIColor
    let currency: Currency
    let amount: NSDecimalNumber
    let percents: NSDecimalNumber
    let coloringType: GraphTransactionFilterColoringType
    
    var amountFormatted: String? {
        return amount.moneyCurrencyString(with: currency, shouldRound: false)
    }
    
    var percentsFormatted: String? {
        return percentsFormatter.string(from: percents)
    }
    
    lazy var percentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = "%"
        return formatter
    }()
    
    init(id: Int,
         type: TransactionableType,
         title: String,
         iconURL: URL?,
         iconPlaceholder: String? = nil,
         сurrency: Currency,
         amount: NSDecimalNumber,
         percents: NSDecimalNumber,
         color: UIColor,
         coloringType: GraphTransactionFilterColoringType = .icon) {
        
        self.currency = сurrency
        self.amount = amount
        self.percents = percents
        self.color = color
        self.coloringType = coloringType
        super.init(id: id, title: title, type: type, iconURL: iconURL, iconPlaceholder: iconPlaceholder ?? type.defaultIconName)
    }
}
