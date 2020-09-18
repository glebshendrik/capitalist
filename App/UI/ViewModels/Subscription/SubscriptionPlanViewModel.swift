//
//  SubscriptionPlanViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class SubscriptionPlanViewModel {
    var isFree: Bool = false
    
    private var planItems: [SubscriptionPlanItemViewModel]
    
    var numberOfPlanItems: Int {
        return planItems.count
    }
    
    func planItemViewModel(by indexPath: IndexPath) -> SubscriptionPlanItemViewModel? {
        return planItems[safe: indexPath.row]
    }
    
    func planItemViewModel(by itemType: SubscriptionPlanItemType) -> SubscriptionPlanItemViewModel? {
        return planItems.first { $0.itemType == itemType }
    }
    
    init(title: String, description: String, features: [PlanFeatureItemViewModel], firstProduct: SubscriptionProduct? = nil, secondProduct: SubscriptionProduct? = nil, products: [ProductViewModel] = [], basicProduct: SubscriptionProduct? = nil, isFree: Bool = false, selectedProduct: SubscriptionProduct? = nil) {
        
        self.isFree = isFree
        planItems = []
        
        planItems.append(PlanSpaceItemViewModel())
        planItems.append(PlanTopItemViewModel())
        planItems.append(PlanTitleItemViewModel(title: title))
        planItems.append(PlanDescriptionItemViewModel(description: description))
        if isFree {
            planItems.append(PlanFreeItemViewModel())
        }
        else if let firstProduct = firstProduct,
                let secondProduct = secondProduct {
            planItems.append(PlanPurchaseItemViewModel(firstProduct: firstProduct,
                                                       secondProduct: secondProduct,
                                                       products: products,
                                                       basicProduct: basicProduct,
                                                       selectedProduct: selectedProduct))
        }
        planItems.append(contentsOf: features)
        planItems.append(PlanBottomItemViewModel())
        planItems.append(PlanSpaceItemViewModel())
        planItems.append(PlanSpaceItemViewModel())
        planItems.append(PlanInfoItemViewModel())
    }
    
    func updateEligibility(productId: String, isTrialAvailable: Bool) {
        guard let planPurchaseItem = planItemViewModel(by: .purchase) as? PlanPurchaseItemViewModel else { return }
        planPurchaseItem.updateEligibility(productId: productId, isTrialAvailable: isTrialAvailable)
    }
}
