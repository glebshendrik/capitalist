//
//  BasketsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class BasketsViewModel {
    private var basketViewModels: [BasketViewModel]
    
    private let minRatio: CGFloat = 0.15
    private var ratioToSpread: CGFloat {
        return 1.0 - minRatio * 3
    }
    
    public private(set) var selectedBasketType: BasketType = .joy
    
    var isJoyBasketSelected: Bool { return selectedBasketType == .joy }
    var isSafeBasketSelected: Bool { return selectedBasketType == .safe }
    var isRiskBasketSelected: Bool { return selectedBasketType == .risk }
    
    public private(set) var joyRatio: CGFloat = 1.0
    public private(set) var riskRatio: CGFloat = 0.0
    public private(set) var safeRatio: CGFloat = 0.0
    
    var joyBasketRatio: CGFloat {
        return basketRatio(joyRatio)
    }

    var safeBasketRatio: CGFloat {
        return basketRatio(safeRatio)
    }
    
    var riskBasketRatio: CGFloat {
        return basketRatio(riskRatio)
    }
       
    var joyBasketSpent: String? {
        return basketViewModelBy(basketType: .joy)?.spent
    }
    
    var riskBasketSpent: String? {
        return basketViewModelBy(basketType: .risk)?.spent
    }
    
    var safeBasketSpent: String? {
        return basketViewModelBy(basketType: .safe)?.spent
    }
    
    init(baskets: [Basket], basketTypeToSelect: BasketType) {
        basketViewModels = baskets.map { BasketViewModel(basket: $0) }
        selectBasketType(basketTypeToSelect)
    }
        
    func selectBasketType(_ basketType: BasketType) {
        selectedBasketType = basketType
        didSelectBasketType()
    }
    
    func updateRatios(joyRatio: CGFloat, safeRatio: CGFloat, riskRatio: CGFloat) {
        self.joyRatio = joyRatio
        self.safeRatio = safeRatio
        self.riskRatio = riskRatio
        didUpdateRatios()
    }
     
    private func didSelectBasketType() {
        switch selectedBasketType {
        case .joy:
            updateRatios(joyRatio: 1.0, safeRatio: 0.0, riskRatio: 0.0)
        case .safe:
            updateRatios(joyRatio: 0.0, safeRatio: 1.0, riskRatio: 0.0)
        case .risk:
            updateRatios(joyRatio: 0.0, safeRatio: 0.0, riskRatio: 1.0)
        }
    }
    
    private func didUpdateRatios() {
        if joyRatio == 1.0 {
            selectedBasketType = .joy
        }
        if safeRatio == 1.0 {
            selectedBasketType = .safe
        }
        if riskRatio == 1.0 {
            selectedBasketType = .risk
        }
    }
    
    private func basketRatio(_ ratio: CGFloat) -> CGFloat {
        return minRatio + ratioToSpread * ratio
    }
    
    private func basketViewModelBy(basketType: BasketType) -> BasketViewModel? {
        return basketViewModels.first { $0.basketType == basketType }
    }
}
