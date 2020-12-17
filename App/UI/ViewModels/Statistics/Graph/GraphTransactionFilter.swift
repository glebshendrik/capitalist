//
//  GraphTransactionFilter.swift
//  Capitalist
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
    let isVirtualTransactionable: Bool
    let isBorrowOrReturnTransactionable: Bool
    
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
    
    var key: String {
        return "\(type)_\(id)"
    }
    
    init(id: Int,
         type: TransactionableType,
         isVirtualTransactionable: Bool,
         isBorrowOrReturnTransactionable: Bool,
         title: String,
         iconURL: URL?,
         iconPlaceholder: String? = nil,
         сurrency: Currency,
         amount: NSDecimalNumber,
         percents: NSDecimalNumber,
         color: UIColor,
         coloringType: GraphTransactionFilterColoringType = .icon) {
        
        self.isVirtualTransactionable = isVirtualTransactionable
        self.isBorrowOrReturnTransactionable = isBorrowOrReturnTransactionable
        self.currency = сurrency
        self.amount = amount
        self.percents = percents
        self.color = color
        self.coloringType = coloringType
        super.init(id: id, title: title, type: type, iconURL: iconURL, iconPlaceholder: iconPlaceholder ?? type.defaultIconName)
    }
}

class CompoundGraphTransactionFilter : GraphTransactionFilter {
    let filters: [GraphTransactionFilter]
    
    init(id: Int,
         type: TransactionableType,
         isVirtualTransactionable: Bool,
         isBorrowOrReturnTransactionable: Bool,
         title: String,
         iconURL: URL?,
         iconPlaceholder: String? = nil,
         сurrency: Currency,
         amount: NSDecimalNumber,
         percents: NSDecimalNumber,
         color: UIColor,
         coloringType: GraphTransactionFilterColoringType = .icon,
         filters: [GraphTransactionFilter]) {
        
        self.filters = filters
        super.init(id: id, type: type, isVirtualTransactionable: isVirtualTransactionable, isBorrowOrReturnTransactionable: isBorrowOrReturnTransactionable, title: title, iconURL: iconURL, iconPlaceholder: iconPlaceholder, сurrency: сurrency, amount: amount, percents: percents, color: color, coloringType: coloringType)
    }
}
