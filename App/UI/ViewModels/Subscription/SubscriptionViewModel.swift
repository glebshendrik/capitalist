//
//  SubscriptionViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import StoreKit
import ApphudSDK
import PromiseKit

enum SubscriptionError : Error {
    case productIsNotChosen
    case purchaseFailed
    case restoreFailed
}

enum SubscriptionProduct : CaseIterable {
    static var allCases: [SubscriptionProduct] {
        return Array(RenewalInterval.allCases.map{ [SubscriptionProduct.basic($0),
                                                    SubscriptionProduct.standard($0),
                                                    SubscriptionProduct.premium($0)] }.joined())
    }
    
    case basic(RenewalInterval)
    case standard(RenewalInterval)
    case premium(RenewalInterval)
    
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
        case .basic(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.main.\(interval.id)"
        case .standard(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.standard.\(interval.id)"
        case .premium(let interval):
            return "com.realtransitapps.threebaskets.subscriptions.premium.\(interval.id)"
        }
    }
}

class SubscriptionViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var subscriptionPlanViewModels: [SubscriptionPlanViewModel] = []
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func updateProducts() {
        let products = accountCoordinator.subscriptionProducts
        var productViewModels = [String : ProductViewModel]()
        for product in products {
            productViewModels[product.productIdentifier] = ProductViewModel(product: product)
        }
        let basicProducts = [productViewModels[SubscriptionProduct.basic(.month).id],
                             productViewModels[SubscriptionProduct.basic(.year).id]].compactMap { $0 }
        let standardProducts = [productViewModels[SubscriptionProduct.standard(.month).id],
                                productViewModels[SubscriptionProduct.standard(.year).id]].compactMap { $0 }
        let premiumProducts = [productViewModels[SubscriptionProduct.premium(.month).id],
                               productViewModels[SubscriptionProduct.premium(.year).id]].compactMap { $0 }
        
        
        let freeFeatures = [FeatureDescriptionViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день", comment: "Неограниченное количество транзакций в день"),
                                    imageName: "subscription-transactions"),
                            FeatureDescriptionViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
                                    imageName: "subscription-assets"),
                            FeatureDescriptionViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
                                    imageName: "subscription-statistics"),
                            FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
                                    imageName: "subscription-credits"),
                            FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
                                    imageName: "subscription-debts")]
        
        let basicFeatures = [FeatureDescriptionViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день", comment: "Неограниченное количество транзакций в день"),
                                    imageName: "subscription-transactions"),
                             FeatureDescriptionViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
                                    imageName: "subscription-assets"),
                             FeatureDescriptionViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
                                    imageName: "subscription-statistics"),
                             FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
                                    imageName: "subscription-credits"),
                             FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
                                    imageName: "subscription-debts")]
        
        let standardFeatures = [FeatureDescriptionViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день", comment: "Неограниченное количество транзакций в день"),
               imageName: "subscription-transactions"),
        FeatureDescriptionViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
               imageName: "subscription-assets"),
        FeatureDescriptionViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
               imageName: "subscription-statistics"),
        FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
               imageName: "subscription-credits"),
        FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
               imageName: "subscription-debts")]
        
        subscriptionPlanViewModels = [
        
//        productViewModels[selectedProductId.id]?.isSelected = true
        updateDiscountPercents()
    }
    
    func checkIntroductoryEligibility() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.checkIntroductoryEligibility()
                }.get { result in
                    self.updateProducts()
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
}


