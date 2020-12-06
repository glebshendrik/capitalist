//
//  SubscriptionViewModel.swift
//  Capitalist
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
    
    var requiredPlans: [SubscriptionPlan] = []
    
    private var userHasRegionDiscount: Bool {
        return ["AZ", "AM", "BY", "KZ", "RU", "TJ", "TM", "UA", "UZ"]
                .map { $0.lowercased() }
                .contains(Locale.autoupdatingCurrent.regionCode?.lowercased())
    }
    
    private var unlimitedPremiumSubscriptionProduct: SubscriptionProduct {
        return userHasRegionDiscount ? .premiumUnlimited(.cis) : .premiumUnlimited(.nonCis)
    }
    
    private var firstPlatinumSubscriptionProduct: SubscriptionProduct {
        return accountCoordinator.hasPremiumUnlimitedSubscription ? .platinumPure(.month) : .platinum(.month)
    }
    
    private var secondPlatinumSubscriptionProduct: SubscriptionProduct {
        return accountCoordinator.hasPremiumUnlimitedSubscription ? .platinumPure(.year) : .platinum(.year)
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator        
    }
    
    func subscriptionPlanViewModel(by indexPath: IndexPath) -> SubscriptionPlanViewModel? {
        return subscriptionPlanViewModels[safe: indexPath.item]
    }
    
    func updateProducts() {
        if requiredPlans.isEmpty {
            requiredPlans = [.free, .premium, .platinum]
        }
        subscriptionPlanViewModels = []
        let products = accountCoordinator.subscriptionProducts
        var productViewModels = [String : ProductViewModel]()
        for product in products {
            productViewModels[product.productIdentifier] = ProductViewModel(product: product)
        }
        
        let premiumProducts = [productViewModels[SubscriptionProduct.premium(.month).id],
                               productViewModels[SubscriptionProduct.premium(.year).id]].compactMap { $0 }
        let premiumUnlimitedProduct = productViewModels[unlimitedPremiumSubscriptionProduct.id]
        let platinumProducts = [productViewModels[firstPlatinumSubscriptionProduct.id],
                                productViewModels[secondPlatinumSubscriptionProduct.id]].compactMap { $0 }        
        
        let freeFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Создание кошельков", comment: ""),
                                                     imageName: "feature-wallet"),
                            PlanFeatureItemViewModel(description:  NSLocalizedString("Создание источников доходов и категорий трат", comment: ""),
                                                     imageName: "feature-calculator"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("До 30 транзакций в день", comment: ""),
                                                     imageName: "feature-transfer"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("Просмотр статистики за текущий и прошлый месяц", comment: ""),
                                                     imageName: "feature-statistics"),
                            PlanFeatureItemViewModel(description: NSLocalizedString("Создание одного актива сбережения и одного актива инвестиции", comment: ""),
                                                     imageName: "feature-assets")]
        
        let premiumFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Неограниченное количество транзакций в день", comment: ""),
                                                        imageName: "feature-transfer"),
                               PlanFeatureItemViewModel(description:  NSLocalizedString("Просмотр статистики за все время с возможностью фильтрации", comment: ""),
                                                        imageName: "feature-statistics"),
                               PlanFeatureItemViewModel(description: NSLocalizedString("Неограниченное количество сбережений и инвестиций", comment: ""),
                                                        imageName: "feature-assets"),
                               PlanFeatureItemViewModel(description: NSLocalizedString("Управление кредитами, долгами и займами", comment: ""),
                                                        imageName: "feature-credits")]
        
        let platinumFeatures = [PlanFeatureItemViewModel(description: NSLocalizedString("Интеграция с банками", comment: ""),
                                                         imageName: "feature-bank")]
//        ,
//                                PlanFeatureItemViewModel(description:  NSLocalizedString("Анализ банковской деятельности за прошлый год", comment: ""),
//                                                         imageName: "feature-analysis")]
        
        if requiredPlans.contains(.free) {
            subscriptionPlanViewModels = [SubscriptionPlanViewModel(title: NSLocalizedString("Бесплатная", comment: ""),
                                                                    description: NSLocalizedString("Бесплатная", comment: ""),
                                                                    features: freeFeatures,
                                                                    isFree: true)]
        }
        
        if !premiumProducts.isEmpty && requiredPlans.contains(.premium) {
            subscriptionPlanViewModels.append(SubscriptionPlanViewModel(title: NSLocalizedString("Premium", comment: ""),
                                                                        description: NSLocalizedString("Включает в себя все функции предыдущего плана", comment: ""),
                                                                        features: premiumFeatures,
                                                                        firstProduct: .premium(.month),
                                                                        secondProduct: .premium(.year),
                                                                        products: premiumProducts,
                                                                        basicProduct: .premium(.month),
                                                                        selectedProduct: .premium(.year),
                                                                        unlimitedProduct: premiumUnlimitedProduct))
        }
        
        if !platinumProducts.isEmpty && requiredPlans.contains(.platinum) {
            subscriptionPlanViewModels.append(SubscriptionPlanViewModel(title: NSLocalizedString("Platinum", comment: ""),
                                                                        description: NSLocalizedString("Включает в себя все функции предыдущего плана", comment: ""),
                                                                        features: platinumFeatures,
                                                                        firstProduct: firstPlatinumSubscriptionProduct,
                                                                        secondProduct: secondPlatinumSubscriptionProduct,
                                                                        products: platinumProducts,
                                                                        basicProduct: firstPlatinumSubscriptionProduct,
                                                                        selectedProduct: secondPlatinumSubscriptionProduct))
        }
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
                }.then { _ in
                    return self.accountCoordinator.updateUserSubscription()
                }
    }
    
    func restore() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.restoreSubscriptions()
                }.then { _ in
                    return self.accountCoordinator.updateUserSubscription()
                }
    }
}


