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
    private var ratioViewModels: [BasketRatioViewModel] = []
    
    var joyBasketSpent: String? {
        return basketViewModelBy(basketType: .joy)?.spent
    }
    
    var riskBasketSpent: String? {
        return basketViewModelBy(basketType: .risk)?.spent
    }
    
    var safeBasketSpent: String? {
        return basketViewModelBy(basketType: .safe)?.spent
    }
    
    var spent: String? {
        guard let currency = basketViewModels.first?.currency else { return nil }
        return basketsSpentCents.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var joyBasketRatio: CGFloat {
        guard isAnySelected else { return 0.333 }
        return isJoyBasketSelected ? 0.7 : 0.15
//        return ratioViewModelBy(basketType: .joy)?.ratio ?? 0.333
    }
    
    var riskBasketRatio: CGFloat {
        guard isAnySelected else { return 0.333 }
        return isRiskBasketSelected ? 0.7 : 0.15
//        return ratioViewModelBy(basketType: .risk)?.ratio ?? 0.333
    }
    
    var safeBasketRatio: CGFloat {
        guard isAnySelected else { return 0.334 }
        return isSafeBasketSelected ? 0.7 : 0.15
//        return ratioViewModelBy(basketType: .safe)?.ratio ?? 0.334
    }
    
    var selectedBasketId: Int? {
        return basketViewModels.first { $0.selected }?.id
    }
    
    var isAnySelected: Bool {
        return isJoyBasketSelected || isSafeBasketSelected || isRiskBasketSelected
    }
    
    var isJoyBasketSelected: Bool {
        return isBasketSelectedWith(basketType: .joy)
    }
    
    var isRiskBasketSelected: Bool {
        return isBasketSelectedWith(basketType: .risk)
    }
    
    var isSafeBasketSelected: Bool {
        return isBasketSelectedWith(basketType: .safe)
    }
    
    var selectedBasketType: BasketType? {
        return selectedBasketViewModel()?.basketType
    }
    
    private var joyBasketSpentCents: Int {
        return basketViewModelBy(basketType: .joy)?.spentCents ?? 0
    }
    
    private var riskBasketSpentCents: Int {
        return basketViewModelBy(basketType: .risk)?.spentCents ?? 0
    }
    
    private var safeBasketSpentCents: Int {
        return basketViewModelBy(basketType: .safe)?.spentCents ?? 0
    }
    
    private var basketsSpentCents: Int {
        return joyBasketSpentCents + riskBasketSpentCents + safeBasketSpentCents
    }
    
    init(baskets: [Basket], basketTypeToSelect: BasketType?) {
        basketViewModels = baskets.map { BasketViewModel(basket: $0) }
        selectBasketBy(basketType: basketTypeToSelect ?? .joy)
//        updateRatios()
    }
    
    func append(cents: Int, basketType: BasketType) {
        basketViewModelBy(basketType: basketType)?.append(cents: cents)
//        updateRatios()
    }
    
    func selectBasketBy(basketType: BasketType) {
        basketViewModels.forEach { $0.unselect() }
        basketViewModelBy(basketType: basketType)?.select()
    }
    
    private func updateRatios() {
        ratioViewModels = basketViewModels
            .map { BasketRatioViewModel(basketViewModel: $0, basketsSpentCents: self.basketsSpentCents) }
            .sorted(by: { $0.ratio < $1.ratio })
        roundRatios()
    }
    
    private func roundRatios() {
        guard   ratioViewModels.reduce(0, { $0 + $1.ratio }) != 1.0,
                let minRatioViewModel = ratioViewModels.item(at: 0),
                let middleRatioViewModel = ratioViewModels.item(at: 1),
                let maxRatioViewModel = ratioViewModels.item(at: 2) else { return }
        
        maxRatioViewModel.ratio = 1.0 - middleRatioViewModel.ratio - minRatioViewModel.ratio
    }
    
    private func basketViewModelBy(basketType: BasketType) -> BasketViewModel? {
        return basketViewModels.first { $0.basketType == basketType }
    }
    
    private func ratioViewModelBy(basketType: BasketType) -> BasketRatioViewModel? {
        return ratioViewModels.first { $0.basketType == basketType }
    }
    
    private func selectedBasketViewModel() -> BasketViewModel? {
        return basketViewModels.first { $0.selected }
    }
    
    private func isBasketSelectedWith(basketType: BasketType) -> Bool {
        guard let selectedBasketViewModel = selectedBasketViewModel() else { return false }
        return selectedBasketViewModel.basketType == basketType
    }
}

class BasketRatioViewModel {
    private let basketViewModel: BasketViewModel
    private let basketsSpentCents: Int
    
    var basketType: BasketType {
        return basketViewModel.basketType
    }
    
    var ratio: CGFloat = 0.0
    
    init(basketViewModel: BasketViewModel, basketsSpentCents: Int) {
        self.basketViewModel = basketViewModel
        self.basketsSpentCents = basketsSpentCents
        self.ratio = calculateRatio()
    }
    
    private func calculateRatio() -> CGFloat {
        guard basketsSpentCents > 0 else { return 1 / 3.0 }
        
        let originalRatio = CGFloat(basketViewModel.spentCents) / CGFloat(basketsSpentCents)
        
        if originalRatio < 0.01 {
            return 0.01
        }
        
        return originalRatio
    }
}
