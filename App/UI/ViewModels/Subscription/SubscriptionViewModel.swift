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

enum SubscriptionProductId : String {
    case monthly = "com.realtransitapps.threebaskets.subscriptions.main.monthly"
    case halfofyear = "com.realtransitapps.threebaskets.subscriptions.main.halfofyear"
    case yearly = "com.realtransitapps.threebaskets.subscriptions.main.yearly"
    
    var id: String {
        return rawValue
    }
}

struct FeatureDescriptionViewModel {
    var description: String
    var imageName: String
}

class SubscriptionViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var productViewModels: [String : ProductViewModel] = [:]
    private var featureDescriptionViewModels: [FeatureDescriptionViewModel] =
        [FeatureDescriptionViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день", comment: "Неограниченное количество транзакций в день"),
                                     imageName: "subscription-transactions"),
         FeatureDescriptionViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
                                     imageName: "subscription-assets"),
         FeatureDescriptionViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
                                     imageName: "subscription-statistics"),
         FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
                                     imageName: "subscription-credits"),
         FeatureDescriptionViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
                                     imageName: "subscription-debts")]
    
    var selectedProductId: SubscriptionProductId = .yearly {
        didSet {
            updateSelectedProduct()
        }
    }
    
    var selectedProduct: ProductViewModel? {
        return productViewModels[selectedProductId.id]
    }
    
    var numberOfFeatureDescriptions: Int {
        return featureDescriptionViewModels.count
    }
    
    var privacyURLString: String {
        return NSLocalizedString("privacy policy url", comment: "privacy policy url")
    }
    
    var termsURLString: String {
        return NSLocalizedString("terms of service url", comment: "terms of service url")
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
    }
    
    func featureDescriptionViewModel(by indexPath: IndexPath) -> FeatureDescriptionViewModel? {
        return featureDescriptionViewModels[safe: indexPath.row]
    }
    
    func productViewModel(by productId: SubscriptionProductId) -> ProductViewModel? {
        return productViewModels[productId.id]
    }
    
    func updateProducts() {
        let products = accountCoordinator.subscriptionProducts
        productViewModels = [String : ProductViewModel]()
        for product in products {
            productViewModels[product.productIdentifier] = ProductViewModel(product: product)
        }
        productViewModels[selectedProductId.id]?.isSelected = true
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
    
    private func updateSelectedProduct() {
        productViewModels.values.forEach { $0.isSelected = false }
        productViewModels[selectedProductId.id]?.isSelected = true
    }
    
    private func updateDiscountPercents() {
        guard let basicProduct = productViewModels[SubscriptionProductId.monthly.id] else { return }
        productViewModels.values.forEach {
            $0.savingPercent = $0.product.savingPercentAgainst(basicProduct.product)
            $0.baseProduct = basicProduct.product
        }
    }
}


