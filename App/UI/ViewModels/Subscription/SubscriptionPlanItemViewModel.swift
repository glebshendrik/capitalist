//
//  SubscriptionPlanItemViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

enum SubscriptionPlanItemType {
    case top
    case title
    case description
    case purchase
    case unlimited
    case free
    case feature
    case bottom
    case space
    case info
    
    var cellIdentifier: String {
        switch self {
        case .top:
            return "SubscriptionPlanItemTopCell"
        case .title:
            return "SubscriptionPlanItemTitleCell"
        case .description:
            return "SubscriptionPlanItemDescriptionCell"
        case .purchase:
            return "SubscriptionPlanItemPurchaseCell"
        case .unlimited:
            return "SubscriptionPlanItemUnlimitedCell"
        case .free:
            return "SubscriptionPlanItemFreeCell"
        case .feature:
            return "SubscriptionPlanItemFeatureCell"
        case .bottom:
            return "SubscriptionPlanItemBottomCell"
        case .space:
            return "SubscriptionPlanItemSpaceCell"
        case .info:
            return "SubscriptionPlanItemInfoCell"
        }
    }
}

protocol SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType { get }
    var cellIdentifier: String { get }
}

extension SubscriptionPlanItemViewModel {
    var cellIdentifier: String {
        return itemType.cellIdentifier
    }
}

class PlanTopItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .top
    }
}

class PlanTitleItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .title
    }
    
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

class PlanDescriptionItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .description
    }
    
    let description: String
    
    init(description: String) {
        self.description = description
    }
}

class PlanPurchaseItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .purchase
    }
    
    let firstProduct: SubscriptionProduct
    let secondProduct: SubscriptionProduct
    
    var productViewModels: [String : ProductViewModel] = [:]
    
    var selectedProduct: SubscriptionProduct? = nil {
        didSet {
            updateSelectedProduct()
        }
    }
    
    var selectedProductViewModel: ProductViewModel? {
        guard let selectedProduct = selectedProduct else { return nil }
        return productViewModels[selectedProduct.id]
    }
    
    init(firstProduct: SubscriptionProduct, secondProduct: SubscriptionProduct, products: [ProductViewModel] = [], basicProduct: SubscriptionProduct? = nil, selectedProduct: SubscriptionProduct? = nil) {
        
        self.firstProduct = firstProduct
        self.secondProduct = secondProduct
        for product in products {
            self.productViewModels[product.identifier] = product
        }
        if let selectedProduct = selectedProduct {
            self.selectedProduct = selectedProduct
            updateSelectedProduct()
        }
        if let basicProduct = basicProduct {
            updateDiscountPercents(basicProduct: basicProduct)
        } 
    }
    
    func productViewModel(by product: SubscriptionProduct) -> ProductViewModel? {
        return productViewModel(by: product.id)
    }
    
    func productViewModel(by productId: String) -> ProductViewModel? {
        return productViewModels[productId]
    }
    
    func updateEligibility(productId: String, isTrialAvailable: Bool) {
        productViewModel(by: productId)?.isTrialAvailable = isTrialAvailable
    }
    
    private func updateDiscountPercents(basicProduct: SubscriptionProduct) {
        guard let basicProduct = productViewModels[basicProduct.id] else { return }
        productViewModels.values.forEach {
            $0.savingPercent = $0.product.savingPercentAgainst(basicProduct.product)
            $0.baseProduct = basicProduct.product
        }
    }
    
    private func updateSelectedProduct() {
        productViewModels.values.forEach { $0.isSelected = false }
        if let selectedProduct = selectedProduct {
            productViewModels[selectedProduct.id]?.isSelected = true
        }
    }
}

class PlanUnlimitedItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .unlimited
    }
    
    let product: ProductViewModel
    
    var purchaseTitle: String {
        return String(format: NSLocalizedString("Пожизненная за %@", comment: ""), product.product.localizedPrice)
    }
    
    var unlimitedDescriptionMessage: String {
        return NSLocalizedString("Либо вы можете приобрести пожизненную версию", comment: "")
    }
    
    init(product: ProductViewModel) {
        
        self.product = product
    }
}

class PlanFreeItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .free
    }
    
    var freePurchaseTitle: String {
        return NSLocalizedString("Продолжить бесплатно", comment: "")        
    }
}

class PlanFeatureItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .feature
    }
    
    let imageName: String
    let description: String
    
    init(description: String, imageName: String) {
        self.imageName = imageName
        self.description = description
    }
}

class PlanBottomItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .bottom
    }
}

class PlanSpaceItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .space
    }
}

class PlanInfoItemViewModel : SubscriptionPlanItemViewModel {
    var itemType: SubscriptionPlanItemType {
        return .info
    }
    
    var infoMessage: String {
        return NSLocalizedString("Отменить подписку можно в любое время в настройках телефона", comment: "")
    }
    
    var restorePurchaseTitle: String {
        return NSLocalizedString("Восстановить подписку", comment: "")
    }
    
    var privacyButtonTitle: String {
        return NSLocalizedString("Политика конфиденциальности", comment: "")
    }
    
    var termsButtonTitle: String {
        return NSLocalizedString("Правила пользования", comment: "")
    }
}
