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
        return [.premium(.month),
                .premium(.year),
                .premiumUnlimited(.cis),
                .premiumUnlimited(.nonCis),
                .platinum(.month),
                .platinum(.year),
                .platinumPure(.month),
                .platinumPure(.year)]
    }
    
    private static var unlimitedIds: [String] {
        return [SubscriptionProduct.premiumUnlimited(.cis).id,
                SubscriptionProduct.premiumUnlimited(.nonCis).id]
    }
    
    case premium(RenewalInterval)
    case premiumUnlimited(Region)
    case platinum(RenewalInterval)
    case platinumPure(RenewalInterval)
    
    enum RenewalInterval : String, CaseIterable {
        case month = "monthly"
        case sixMonths = "halfofyear"
        case year = "yearly"
        
        var id: String {
            return rawValue
        }
    }
    
    enum Region : String, CaseIterable {
        case cis = "cis"
        case nonCis = ""
        
        var id: String {
            return rawValue
        }
    }
    
    var id: String {
        switch self {
        case .premium(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.main.\(interval.id)"
        case .premiumUnlimited(let region):
            return "com.realtransitapps.threebaskets.subscriptions.main.unlimited\(region.id)"
        case .platinum(let interval):
            return "com.realtransitapps.capitalist.subscriptions.platinum.\(interval.id)"
        case .platinumPure(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.pureplatinum.\(interval.id)"
        }
    }
    
    var plan: SubscriptionPlan {
        switch self {
        case .premium, .premiumUnlimited:
            return .premium
        case .platinum, .platinumPure:
            return .platinum
        }
    }
    
    static func isUnlimited(_ productId: String) -> Bool {
        return unlimitedIds.contains(productId)
    }
}

enum SubscriptionPlan : String {
    case free
    case premium
    case platinum
    
    var id: String {
        return self.rawValue
    }
}
