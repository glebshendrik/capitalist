//
//  BasketsViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 15/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class BasketsViewModel {
    private var basketViewModels: [BasketViewModel]
    private var ratioViewModels: [BasketRatioViewModel] = []
    
    var joyBasketMonthlySpent: String? {
        return basketViewModelBy(basketType: .joy)?.monthlySpent
    }
    
    var riskBasketMonthlySpent: String? {
        return basketViewModelBy(basketType: .risk)?.monthlySpent
    }
    
    var safeBasketMonthlySpent: String? {
        return basketViewModelBy(basketType: .safe)?.monthlySpent
    }
    
    var monthlySpent: String? {
        guard let currency = basketViewModels.first?.currency else { return nil }
        return basketsMonthlySpentCents.moneyCurrencyString(with: currency, shouldRound: true)
    }
    
    var joyBasketRatio: CGFloat {
        return ratioViewModelBy(basketType: .joy)?.ratio ?? 0.333
    }
    
    var riskBasketRatio: CGFloat {
        return ratioViewModelBy(basketType: .risk)?.ratio ?? 0.333
    }
    
    var safeBasketRatio: CGFloat {
        return ratioViewModelBy(basketType: .safe)?.ratio ?? 0.334
    }
    
    var selectedBasketId: Int? {
        return basketViewModels.first { $0.selected }?.id
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
    
    private var joyBasketMonthlySpentCents: Int {
        return basketViewModelBy(basketType: .joy)?.monthlySpentCents ?? 0
    }
    
    private var riskBasketMonthlySpentCents: Int {
        return basketViewModelBy(basketType: .risk)?.monthlySpentCents ?? 0
    }
    
    private var safeBasketMonthlySpentCents: Int {
        return basketViewModelBy(basketType: .safe)?.monthlySpentCents ?? 0
    }
    
    private var basketsMonthlySpentCents: Int {
        return joyBasketMonthlySpentCents + riskBasketMonthlySpentCents + safeBasketMonthlySpentCents
    }
    
    init(baskets: [Basket], basketTypeToSelect: BasketType?) {
        basketViewModels = baskets.map { BasketViewModel(basket: $0) }
        selectBasketBy(basketType: basketTypeToSelect ?? .joy)
        updateRatios()
    }
    
    func append(cents: Int, basketType: BasketType) {
        basketViewModelBy(basketType: basketType)?.append(cents: cents)
        updateRatios()
    }
    
    func selectBasketBy(basketType: BasketType) {
        basketViewModels.forEach { $0.unselect() }
        basketViewModelBy(basketType: basketType)?.select()
    }
    
    private func updateRatios() {
        ratioViewModels = basketViewModels
            .map { BasketRatioViewModel(basketViewModel: $0, basketsMonthlySpentCents: self.basketsMonthlySpentCents) }
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
    private let basketsMonthlySpentCents: Int
    
    var basketType: BasketType {
        return basketViewModel.basketType
    }
    
    var ratio: CGFloat = 0.0
    
    init(basketViewModel: BasketViewModel, basketsMonthlySpentCents: Int) {
        self.basketViewModel = basketViewModel
        self.basketsMonthlySpentCents = basketsMonthlySpentCents
        self.ratio = calculateRatio()
    }
    
    private func calculateRatio() -> CGFloat {
        guard basketsMonthlySpentCents > 0 else { return 1 / 3.0 }
        
        let originalRatio = CGFloat(basketViewModel.monthlySpentCents) / CGFloat(basketsMonthlySpentCents)
        
        if originalRatio < 0.01 {
            return 0.01
        }
        
        return originalRatio
    }
}
