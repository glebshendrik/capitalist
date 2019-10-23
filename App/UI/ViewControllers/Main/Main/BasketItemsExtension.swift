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
    
    func basketItemsPageControl(by basketType: BasketType) -> UIPageControl {
        switch basketType {
        case .joy:
            return joyExpenseCategoriesPageControl
        case .risk:
            return riskActivesPageControl
        case .safe:
            return safeActivesPageControl
        }
    }
}

extension MainViewController {
    func updatePageControl(for scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        switch collectionView {
        case joyExpenseCategoriesCollectionView:    updatePageControl(basketType: .joy)
        case riskActivesCollectionView:   updatePageControl(basketType: .risk)
        case safeActivesCollectionView:   updatePageControl(basketType: .safe)
        default: return
        }
    }
    
    func updatePageControl(basketType: BasketType) {
        let collectionView = basketItemsCollectionView(by: basketType)
        basketItemsPageControl(by: basketType).currentPage = Int(collectionView.contentOffset.x) / Int(collectionView.frame.width)
    }
    
    func updateBasketsItemsPageControl(by basketType: BasketType) {
        let collectionView = basketItemsCollectionView(by: basketType)
        let pageControl = basketItemsPageControl(by: basketType)
        
        guard let layout = collectionView.collectionViewLayout as? PagedCollectionViewLayout else {
            pageControl.isHidden = true
            return
        }
        
        let pagesCount = layout.numberOfPages
        pageControl.numberOfPages = pagesCount
        pageControl.isHidden = pagesCount <= 1
    }
}
