//
//  SubscriptionProduct.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

enum SubscriptionProduct : CaseIterable, Hashable {
    static var allCases: [SubscriptionProduct] {
        return Array(RenewalInterval.allCases.map{ [SubscriptionProduct.premium($0),
                                                    SubscriptionProduct.platinum($0)] }.joined())
    }
    
    case premium(RenewalInterval)
    case platinum(RenewalInterval)
    
    enum RenewalInterval : String, CaseIterable {
        case month = "monthly"
        case sixMonths = "halfofyear"
        case year = "yearly"
        
        var id: String {
            return rawValue
        }
    }
    
    var id: String {
        switch self {
        case .premium(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.main.\(interval.id)"
        case .platinum(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.platinum.\(interval.id)"
        }
    }
}
