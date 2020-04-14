//
//  ActiveEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool) {
        loadActives(by: basketType)
        loadBaskets()
        loadBudget()
        let infoNeededToShow = isIncomePlanned && !UIFlowManager.reached(point: .dependentIncomeSourceMessage)
        loadIncomeSources(scrollToEndWhenUpdated: infoNeededToShow)
        guard infoNeededToShow else { return }
        showDependentIncomeSourceMessage(activeName: name)
    }
    
    func didUpdateActive(with basketType: BasketType) {
        loadActives(by: basketType)
        loadBudget()
        loadIncomeSources()
    }
    
    func didRemoveActive(with basketType: BasketType) {
        loadActives(by: basketType)
        loadBaskets()
        loadBudget()
        loadExpenseSources()
        loadIncomeSources()
    }
}

extension MainViewController {
    private func showDependentIncomeSourceMessage(activeName: String) {
        slideUp(factory.dependentIncomeSourceInfoViewController(activeName: activeName),
                toBottomOf: expenseSourcesCollectionView,
                shouldDim: true)
    }
}

extension MainViewController {
    func didSelectActive(at indexPath: IndexPath, basketType: BasketType) {
        if viewModel.isAddActiveItem(indexPath: indexPath, basketType: basketType) {
            showNewActiveScreen(basketType: basketType)
        } else if let activeViewModel = viewModel.activeViewModel(at: indexPath, basketType: basketType) {            
            if isSelecting {
                select(activeViewModel, collectionView: basketItemsCollectionView(by: basketType), indexPath: indexPath)
            }
            else {
                showActiveInfo(active: activeViewModel)
            }
        }
    }
    
    func activeCollectionViewCell(forItemAt indexPath: IndexPath, basketType: BasketType) -> UICollectionViewCell {
        
        let collectionView = basketItemsCollectionView(by: basketType)
        
        if viewModel.isAddActiveItem(indexPath: indexPath, basketType: basketType) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddActiveCollectionViewCell",
                                                      for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveCollectionViewCell",
                                                            for: indexPath) as? ActiveCollectionViewCell,
            let activeViewModel = viewModel.activeViewModel(at: indexPath,
                                                            basketType: basketType) else {
                                                                                
                                                                                return UICollectionViewCell()
        }
        
        cell.viewModel = activeViewModel
        return cell
    }
}
