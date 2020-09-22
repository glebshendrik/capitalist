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
    
    init(title: String, description: String, features: [PlanFeatureItemViewModel], firstProduct: SubscriptionProduct? = nil, secondProduct: SubscriptionProduct? = nil, products: [ProductViewModel] = [], basicProduct: SubscriptionProduct? = nil, isFree: Bool = false, selectedProduct: SubscriptionProduct? = nil) {
        
        self.isFree = isFree
        planItems = []
        
        planItems.append(PlanTopItemViewModel())
        planItems.append(PlanTitleItemViewModel(title: title))
        if isFree {
            planItems.append(contentsOf: features)
            planItems.append(PlanFreeItemViewModel())
        }
        else if let firstProduct = firstProduct,
                let secondProduct = secondProduct {
            planItems.append(PlanDescriptionItemViewModel(description: description))
            planItems.append(contentsOf: features)
            planItems.append(PlanPurchaseItemViewModel(firstProduct: firstProduct,
                                                       secondProduct: secondProduct,
                                                       products: products,
                                                       basicProduct: basicProduct,
                                                       selectedProduct: selectedProduct))
        }
        
        planItems.append(PlanBottomItemViewModel())
        planItems.append(PlanSpaceItemViewModel())
        if !isFree {
            planItems.append(PlanInfoItemViewModel())
        }
        
    }
    
    func planItemViewModel(by indexPath: IndexPath) -> SubscriptionPlanItemViewModel? {
        return planItems[safe: indexPath.row]
    }
    
    func planItemViewModel(by itemType: SubscriptionPlanItemType) -> SubscriptionPlanItemViewModel? {
        return planItems.first { $0.itemType == itemType }
    }
    
    func updateEligibility(productId: String, isTrialAvailable: Bool) {
        guard let planPurchaseItem = planItemViewModel(by: .purchase) as? PlanPurchaseItemViewModel else { return }
        planPurchaseItem.updateEligibility(productId: productId, isTrialAvailable: isTrialAvailable)
    }
}
