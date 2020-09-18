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

class SubscriptionViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    private var subscriptionPlanViewModels: [SubscriptionPlanViewModel] = []
    
    var numberOfSubscriptionPlans: Int {
        return subscriptionPlanViewModels.count
    }
    
    func subscriptionPlanViewModel(by indexPath: IndexPath) -> SubscriptionPlanViewModel? {
        return subscriptionPlanViewModels[safe: indexPath.item]
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator        
    }
    
    func updateProducts() {
        let products = accountCoordinator.subscriptionProducts
        var productViewModels = [String : ProductViewModel]()
        for product in products {
            productViewModels[product.productIdentifier] = ProductViewModel(product: product)
        }
        
        let premiumProducts = [productViewModels[SubscriptionProduct.premium(.month).id],
                               productViewModels[SubscriptionProduct.premium(.year).id]].compactMap { $0 }
        let platinumProducts = [productViewModels[SubscriptionProduct.platinum(.month).id],
                                productViewModels[SubscriptionProduct.platinum(.year).id]].compactMap { $0 }
        
        
        let freeFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день",
                                                                                       comment: "Неограниченное количество транзакций в день"),
                                                        imageName: "subscription-transactions"),
                            PlanFeatureItemViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций",
                                                                                        comment: "Неограниченное количество сбережений и инвестиций"),
                                                        imageName: "subscription-assets"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций",
                                                                                       comment: "Статистика за все время с возможностью фильтрации операций"),
                                                        imageName: "subscription-statistics"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять кредитами",
                                                                                       comment: "Возможность управлять кредитами"),
                                                        imageName: "subscription-credits"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять долгами и займами",
                                                                                       comment: "Возможность управлять долгами и займами"),
                                                        imageName: "subscription-debts")]
        
        let premiumFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день",
                                                                                        comment: "Неограниченное количество транзакций в день"),
                                    imageName: "subscription-transactions"),
                             PlanFeatureItemViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
                                    imageName: "subscription-assets"),
                             PlanFeatureItemViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
                                    imageName: "subscription-statistics"),
                             PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
                                    imageName: "subscription-credits"),
                             PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
                                    imageName: "subscription-debts")]
        
        let platinumFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день",
                                                                   comment: "Неограниченное количество транзакций в день"),
               imageName: "subscription-transactions"),
        PlanFeatureItemViewModel(description:  NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: "Неограниченное количество сбережений и инвестиций"),
               imageName: "subscription-assets"),
        PlanFeatureItemViewModel(description: NSLocalizedString("Статистика за все время с возможностью фильтрации операций", comment: "Статистика за все время с возможностью фильтрации операций"),
               imageName: "subscription-statistics"),
        PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять кредитами", comment: "Возможность управлять кредитами"),
               imageName: "subscription-credits"),
        PlanFeatureItemViewModel(description: NSLocalizedString("Возможность управлять долгами и займами", comment: "Возможность управлять долгами и займами"),
               imageName: "subscription-debts")]
        
        
        subscriptionPlanViewModels = [SubscriptionPlanViewModel(title: NSLocalizedString("Бесплатная", comment: ""),
                                                                description: NSLocalizedString("Бесплатная", comment: ""),
                                                                features: freeFeatures,
                                                                isFree: true),
                                      SubscriptionPlanViewModel(title: NSLocalizedString("Premium", comment: ""),
                                                                description: NSLocalizedString("Premium", comment: ""),
                                                                features: premiumFeatures,
                                                                firstProduct: .premium(.month),
                                                                secondProduct: .premium(.year),
                                                                products: premiumProducts,
                                                                basicProduct: .premium(.month),
                                                                selectedProduct: .premium(.year)),
                                      SubscriptionPlanViewModel(title: NSLocalizedString("Platinum", comment: ""),
                                                                description: NSLocalizedString("Platinum", comment: ""),
                                                                features: platinumFeatures,
                                                                firstProduct: .platinum(.month),
                                                                secondProduct: .platinum(.year),
                                                                products: platinumProducts,
                                                                basicProduct: .platinum(.month),
                                                                selectedProduct: .platinum(.year))]
    }
    
    
    func checkIntroductoryEligibility() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.checkIntroductoryEligibility()
                }.get { eligibilities in
                    self.updateProducts()
                    eligibilities.forEach { eligibility in
                        self.subscriptionPlanViewModels.forEach { plan in
                            plan.updateEligibility(productId: eligibility.key, isTrialAvailable: eligibility.value)
                        }
                    }
                }.asVoid()
    }
    
    func purchase(product: SKProduct) -> Promise<Void> {
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


