//
//  ActiveEditDelegateExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension MainViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String) {
        loadActives(by: basketType)
        loadBaskets()
        loadBudget()
        guard basketType != BasketType.joy else { return }
        showDependentIncomeSourceMessage(basketType: basketType, name: name)
        didCreateIncomeSource()
    }
    
    func didUpdateActive(with basketType: BasketType) {
        loadActives(by: basketType)
        loadBudget()
        guard basketType != BasketType.joy else { return }
        didUpdateIncomeSource()
    }
    
    func didRemoveActive(with basketType: BasketType) {
        loadActives(by: basketType)
        loadBaskets()
        loadBudget()
        loadExpenseSources()
        guard basketType != BasketType.joy else { return }
        didRemoveIncomeSource()
    }
}

extension MainViewController {
    private func showDependentIncomeSourceMessage(basketType: BasketType, name: String) {
        if let dependentIncomeSourceCreationMessageViewController = router.viewController(.DependentIncomeSourceCreationMessageViewController) as? DependentIncomeSourceCreationMessageViewController,
            let point = uiPoint(of: basketType),
            !UIFlowManager.reached(point: point) {
            
            dependentIncomeSourceCreationMessageViewController.basketType = basketType
            dependentIncomeSourceCreationMessageViewController.name = name
            
            dependentIncomeSourceCreationMessageViewController.modalPresentationStyle = .overCurrentContext
            dependentIncomeSourceCreationMessageViewController.modalTransitionStyle = .crossDissolve
            present(dependentIncomeSourceCreationMessageViewController, animated: true, completion: nil)
            
        }
        
    }
    
    private func uiPoint(of basketType: BasketType) -> UIFlowPoint? {
        switch basketType {
        case .risk:
            return .dependentRiskIncomeSourceMessage
        case .safe:
            return .dependentSafeIncomeSourceMessage
        default:
            return nil
        }
    }
}

extension MainViewController {
    func didSelectActive(at indexPath: IndexPath, basketType: BasketType) {
        if viewModel.isAddActiveItem(indexPath: indexPath, basketType: basketType) {
            showNewActiveScreen(basketType: basketType)
        } else if let activeViewModel = viewModel.activeViewModel(at: indexPath, basketType: basketType) {
            
//            let filterViewModel = ExpenseCategoryTransactionFilter(expenseCategoryViewModel: expenseCategoryViewModel)
//            showStatistics()
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
