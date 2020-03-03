//
//  ProductViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import StoreKit

class ProductViewModel {
    let product: SKProduct
    
    var isSelected: Bool = false
    var isTrialAvailable: Bool = false
    var savingPercent: NSDecimalNumber? = nil
    
    var trialDiscount: SKProductDiscount? {
        if #available(iOS 12.2, *) {
            guard let discount = product.introductoryPrice, discount.paymentMode == .freeTrial else { return nil }
            return discount
        } else {
            return nil
        }
    }
    
    var hasTrial: Bool {
        return trialDiscount != nil
    }
    
    var title: String {
        if let trialPeriod = trialDiscount?.subscriptionPeriod, isTrialAvailable {
            return String.localizedStringWithFormat(NSLocalizedString("%@ бесплатно", comment: "%@ бесплатно"), trialPeriod.localizedPeriod)
        }
        
        if let savingPercent = savingPercent {
            return String.localizedStringWithFormat(NSLocalizedString("Скидка %@", comment: "Скидка %@"), formattedPercent(savingPercent))
        }
        else {
            return NSLocalizedString("Без скидки", comment: "Без скидки")
        }
    }
    
    var subtitle: String {
        if let trialPeriod = trialDiscount?.subscriptionPeriod, isTrialAvailable {
            return String.localizedStringWithFormat(NSLocalizedString("Через %@ %@", comment: "Через %@ %@"), trialPeriod.localizedPeriod, product.localizedPricePerPeriod)
        }
        
        return product.localizedPricePerPeriod
    }
    
    init(product: SKProduct) {
        self.product = product
    }
    
    func formattedPercent(_ percent: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: percent) ?? ""
    }
}

extension SKProduct {
    var localizedPricePerPeriod: String {
        let price = localizedPriceFrom(price: self.price)
        guard let period = subscriptionPeriod else {
            return price
        }
        return String.localizedStringWithFormat(NSLocalizedString("%@ / %@", comment: "%@ / %@"), price, period.localizedPeriod)
    }
    
    func savingPercentAgainst(_ base: SKProduct) -> NSDecimalNumber? {
        guard   productIdentifier != base.productIdentifier,
                let basePeriod = base.subscriptionPeriod,
                let productPeriod = subscriptionPeriod,
                productPeriod.unit.rawValue >= basePeriod.unit.rawValue else { return nil }
        
        if  productPeriod.unit == basePeriod.unit &&
            productPeriod.numberOfUnits < basePeriod.numberOfUnits {
            return nil
        }
        
        let basePriceOfUnit = base.price.dividing(by: NSDecimalNumber(integerLiteral: basePeriod.numberOfUnits))
        let baseUnitsInProductUnit = basePeriod.unit.timesIn(productPeriod.unit)
        let priceWithoutSaving = basePriceOfUnit.multiplying(by: NSDecimalNumber(integerLiteral: baseUnitsInProductUnit * productPeriod.numberOfUnits))
        
        let hundred = NSDecimalNumber(integerLiteral: 1)
        
        let savingPercent = hundred.subtracting(price.dividing(by: priceWithoutSaving))
        return savingPercent.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .down,
                                                                                  scale: 2,
                                                                                  raiseOnExactness: false,
                                                                                  raiseOnOverflow: false,
                                                                                  raiseOnUnderflow: false,
                                                                                  raiseOnDivideByZero: false))
    }
        
    private func localizedPriceFrom(price: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price) ?? ""
    }
}

extension SKProductSubscriptionPeriod {
    var localizedPeriod: String {
        return String.localizedStringWithFormat(unit.localizedFormat, numberOfUnits)
    }
}

extension SKProduct.PeriodUnit {
    var localizedFormat: String {
        switch self {
        case .day:      return NSLocalizedString("period unit days", comment: "")
        case .week:     return NSLocalizedString("period unit weeks", comment: "")
        case .month:    return NSLocalizedString("period unit months", comment: "")
        case .year:     return NSLocalizedString("period unit years", comment: "")
        default:        return ""
        }
    }
    
    func timesIn(_ unit: SKProduct.PeriodUnit) -> Int {
        guard self != unit else { return 1 }
        
        switch (self, unit) {
        case (.day, .week):         return 7
        case (.day, .month):        return 30
        case (.day, .year):         return 365
        case (.week, .month):       return 4
        case (.week, .year):        return 52
        case (.month, .year):       return 12
        default:                    return 0
        }
    }
}