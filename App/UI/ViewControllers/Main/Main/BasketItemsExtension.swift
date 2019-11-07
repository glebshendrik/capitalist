//
//  BasketItemsExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController {
    func basketItemsActivityIndicator(by basketType: BasketType) -> UIView {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesActivityIndicator
        case .risk:
            return riskActivesActivityIndicator
        case .safe:
            return safeActivesActivityIndicator
        }
    }
    
    func basketItemsCollectionView(by basketType: BasketType) -> UICollectionView {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesCollectionView
        case .risk:
            return riskActivesCollectionView
        case .safe:
            return safeActivesCollectionView
        }
    }
}
