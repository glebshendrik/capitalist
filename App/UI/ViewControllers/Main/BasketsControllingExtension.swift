//
//  BasketsControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import BetterSegmentedControl

extension MainViewController {
    func setupBasketsTabs() {
        guard !tabsInitialized else { return }
        basketsTabs.segments = LabelSegment.segments(withTitles: [NSLocalizedString("РАСХОДЫ", comment: "РАСХОДЫ"),
                                                                  NSLocalizedString("СБЕРЕЖЕНИЯ", comment: "СБЕРЕЖЕНИЯ"),
                                                                  NSLocalizedString("ИНВЕСТИЦИИ", comment: "ИНВЕСТИЦИИ")],
                                              normalBackgroundColor: UIColor.clear,
                                              normalFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              normalTextColor: UIColor.by(.white100),
                                              selectedBackgroundColor: UIColor.by(.white12),
                                              selectedFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              selectedTextColor: UIColor.by(.white100))
        basketsTabs.addTarget(self, action: #selector(didChangeBasketTab(_:)), for: .valueChanged)
        tabsInitialized = true
    }
    
    @objc func didChangeBasketTab(_ sender: Any) {
        guard let basketType = basketType(by: basketsTabs.index) else { return }
        didTapBasket(with: basketType)
    }
    
    func didTapBasket(with basketType: BasketType) {
//        scrollBasketAtTopIfNeeded(basketType: basketType)
        viewModel.basketsViewModel.selectBasketType(basketType)
        updateBasketsUI()
    }
    
    func basketType(by index: Int) -> BasketType? {
        return [BasketType.joy, BasketType.safe, BasketType.risk][safe: index]
    }
    
    func indexOfSelectedBasketType() -> Int? {
        return [BasketType.joy, BasketType.safe, BasketType.risk].firstIndex(of: viewModel.basketsViewModel.selectedBasketType)
    }
    
    private func updateTabs() {
        basketsTabs.setIndex(indexOfSelectedBasketType() ?? 0, animated: true)
    }
    
    func updateBasketsUI() {
        updateTabs()
        showBasketContent()
        updateTotalUI(animated: true)
    }
    
    func scrollBasketAtTopIfNeeded(basketType: BasketType) {
        guard basketType == viewModel.basketsViewModel.selectedBasketType else { return }
        let collectionView = basketItemsCollectionView(by: basketType)
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func showBasketContent() {
        basketsContentScrollView.setContentOffset(basketContentOffset(by: viewModel.basketsViewModel.selectedBasketType), animated: true)
    }
    
    func updateBasketTransition() {
        let joyRatio = basketContentRatio(basketType: .joy)
        let safeRatio = basketContentRatio(basketType: .safe)
        let riskRatio = basketContentRatio(basketType: .risk)
        let basketType = viewModel.basketsViewModel.selectedBasketType
        viewModel.basketsViewModel.updateRatios(joyRatio: joyRatio, safeRatio: safeRatio, riskRatio: riskRatio)
        updateTabs()
        if basketType != viewModel.basketsViewModel.selectedBasketType {
            updateTotalUI(animated: false)
        }        
    }
    
    func basketContentRatio(basketType: BasketType) -> CGFloat {
        let width = basketsContentScrollView.frame.width
        let offset = basketsContentScrollView.contentOffset.x
        let basketOffset = basketContentOffset(by: basketType).x
        let distance = (offset - basketOffset).abs
        let diff = width - distance
        if diff < 0 {
            return 0
        }
        return diff / width
    }
    
    func basketContentOffset(by basketType: BasketType) -> CGPoint {
        switch basketType {
        case .joy:
            return CGPoint.zero
        case .safe:
            return CGPoint(x: basketsContentScrollView.frame.width * 1, y: 0)
        case .risk:
            return CGPoint(x: basketsContentScrollView.frame.width * 2, y: 0)
        }
    }
}
