//
//  SubscriptionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import StoreKit
import ApphudSDK
import PromiseKit

enum SubscriptionProductId : String {
    case first = "com.realtransitapps.threebaskets.subscriptions.main.monthly"
    case second = "com.realtransitapps.threebaskets.subscriptions.main.halfofyear"
    case third = "com.realtransitapps.threebaskets.subscriptions.main.yearly"
    
    var id: String {
        return rawValue
    }
}

extension SKProduct.PeriodUnit {
    func timesIn(_ unit: SKProduct.PeriodUnit) -> Int {
        if self == unit {
            return 1
        }
        switch (self, unit) {
        case (.day, .week):
            return 7
        case (.day, .month):
            return 30
        case (.day, .year):
            return 365
        case (.week, .month):
            return 4
        case (.week, .year):
            return 52
        case (.month, .year):
            return 12
        default:
            return 0
        }
    }
}

class ProductViewModel {
    let product: SKProduct
    
    var isSelected: Bool = false
    var isTrialAvailable: Bool = false
    var savingPercent: NSDecimalNumber? = nil
    
    var trialDiscount: SKProductDiscount? {
        if #available(iOS 12.2, *) {
            return product.discounts.first { $0.type == .introductory && $0.paymentMode == .freeTrial }
        } else {
            return nil
        }
    }
    
    var hasTrial: Bool {
        return trialDiscount != nil
    }
    
    
    var title: String {
        if let trialPeriod = trialDiscount?.subscriptionPeriod, isTrialAvailable {
            return String.localizedStringWithFormat(NSLocalizedString("%@ бесплатно", comment: "%@ бесплатно"), periodStringFrom(trialPeriod))
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
            return String.localizedStringWithFormat(NSLocalizedString("Через %@ %@", comment: "Через %@ %@"), periodStringFrom(trialPeriod), pricePerPeriod())
        }
        
        return pricePerPeriod()
    }
    
    init(product: SKProduct) {
        self.product = product
    }
    
    func savingPercentAgainst(_ base: SKProduct) -> NSDecimalNumber? {
        guard   product.productIdentifier != base.productIdentifier,
                let basePeriod = base.subscriptionPeriod,
                let productPeriod = product.subscriptionPeriod,
                productPeriod.unit.rawValue >= basePeriod.unit.rawValue else { return nil }
        
        if  productPeriod.unit == basePeriod.unit &&
            productPeriod.numberOfUnits < basePeriod.numberOfUnits {
            return nil
        }
        
        let basePriceOfUnit = base.price.dividing(by: NSDecimalNumber(integerLiteral: basePeriod.numberOfUnits))
        let baseUnitsInProductUnit = basePeriod.unit.timesIn(productPeriod.unit)
        let priceWithoutSaving = basePriceOfUnit.multiplying(by: NSDecimalNumber(integerLiteral: baseUnitsInProductUnit * productPeriod.numberOfUnits))
        
        let hundred = NSDecimalNumber(integerLiteral: 100)
        
        let savingPercent = hundred.subtracting(product.price.multiplying(by: hundred).dividing(by: priceWithoutSaving))
        return savingPercent.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
        
    }
    
    func pricePerPeriod() -> String {
        let price = localizedPriceFrom(price: product.price)
        guard let period = product.subscriptionPeriod else {
            return price
        }
        return "\(price) / \(periodStringFrom(period))"
    }
    
    func periodStringFrom(_ period: SKProductSubscriptionPeriod) -> String {
        return String.localizedStringWithFormat(unitFormatStringFrom(period.unit), period.numberOfUnits)
    }
    
    func unitFormatStringFrom(_ unit: SKProduct.PeriodUnit) -> String {
        switch unit {
        case .day:      return NSLocalizedString("period unit days", comment: "")
        case .week:     return NSLocalizedString("period unit weeks", comment: "")
        case .month:    return NSLocalizedString("period unit months", comment: "")
        case .year:     return NSLocalizedString("period unit years", comment: "")
        default:        return ""
        }
    }
    
    func localizedPriceFrom(price: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: price) ?? ""
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

enum SubscriptionError : Error {
    case productIsNotChosen
    case purchaseFailed
    case restoreFailed
}

class SubscriptionViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var productViewModels: [String : ProductViewModel] = [:]
    
    var selectedProductId: SubscriptionProductId = .first {
        didSet {
            updateSelectedProduct()
        }
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
        loadData()
    }
    
    func loadData() {
        let products = accountCoordinator.subscriptionProducts
        productViewModels = [String : ProductViewModel]()
        for product in products {
            productViewModels[product.productIdentifier] = ProductViewModel(product: product)
        }
        productViewModels[selectedProductId.id]?.isSelected = true
    }
    
    func checkIntroductoryEligibility() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.checkIntroductoryEligibility()
                }.get { result in
                    result.forEach { self.productViewModels[$0.key]?.isTrialAvailable = $0.value }
                }.asVoid()
    }
    
    func purchase() -> Promise<Void> {
        guard let product = productViewModels[selectedProductId.id]?.product else {
            return Promise(error: SubscriptionError.productIsNotChosen)
        }
        return  firstly {
                    accountCoordinator.purchase(product: product)
                }.map { subscription -> ApphudSubscription in
                    guard let subscription = subscription, subscription.isActive() else { throw SubscriptionError.purchaseFailed }
                    return subscription
                }.then { _ in
                    return self.accountCoordinator.updateUserSubscription()
                }
    }
    
    func restore() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.restoreSubscriptions()
                }.map { subscriptions -> [ApphudSubscription] in
                    guard let subscriptions = subscriptions, subscriptions.any(matching: { $0.isActive() }) else { throw SubscriptionError.restoreFailed }
                    return subscriptions
                }.then { _ in
                    return self.accountCoordinator.updateUserSubscription()
                }
    }
    
    private func updateSelectedProduct() {
        productViewModels.values.forEach { $0.isSelected = false }
        productViewModels[selectedProductId.id]?.isSelected = true
    }
}

extension SKProduct {
    
    
}

extension ApphudSubscriptionStatus {
    /**
     This function can only be used in Swift
     */
    func toStringDuplicate() -> String {
        
        switch self {
        case .trial:
            return "trial"
        case .intro:
            return "intro"
        case .promo:
            return "promo"
        case .grace:
            return "grace"
        case .regular:
            return "regular"
        case .refunded:
            return "refunded"
        case .expired:
            return "expired"
        default:
            return ""
        }
    }
}
