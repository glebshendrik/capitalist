//
//  SubscriptionPlanViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

struct FeatureDescriptionViewModel {
    var description: String
    var imageName: String
}

class SubscriptionPlanViewModel {
    let title: String
    let description: String
    let isFree: Bool = false
    let productViewModels: [String : ProductViewModel] = [:]
    let featureDescriptionViewModels: [FeatureDescriptionViewModel]
    
    var selectedProductId: SubscriptionProduct {
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
    
    func featureDescriptionViewModel(by indexPath: IndexPath) -> FeatureDescriptionViewModel? {
        return featureDescriptionViewModels[safe: indexPath.row]
    }
    
    func productViewModel(by productId: SubscriptionProductId) -> ProductViewModel? {
        return productViewModels[productId.id]
    }
    
    init(title: String, description: String, features: [FeatureDescriptionViewModel], products: [ProductViewModel] = [], isFree: Bool = false, selectedProduct: SubscriptionProduct? = nil) {
        
        self.title = title
        self.description = description
        self.featureDescriptionViewModels = features
        
        for product in products {
            self.productViewModels[product.identifier] = product
        }
        self.isFree = isFree
        if let selectedProductId = selectedProductId {
            self.selectedProductId = selectedProductId
        }
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
