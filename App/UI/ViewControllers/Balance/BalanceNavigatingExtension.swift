//
//  BalanceNavigatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension BalanceViewController : BalanceExpenseSourcesTableSupportDelegate, BalanceActivesTableSupportDelegate, ActiveEditViewControllerDelegate {
    
    
    
    func didSelect(expenseSource: ExpenseSourceViewModel) {
        showStatistics(with: expenseSource.asTransactionFilter())
    }
    
    func didSelect(active: ActiveViewModel) {
        modal(factory.activeEditViewController(delegate: self,
                                               active: active.active,
                                               basketType: active.basketType))
    }
    
    func didCreateActive(with basketType: BasketType, name: String) {
        
    }
    
    func didUpdateActive(with basketType: BasketType) {
        loadBudget()
        loadActives(finantialDataInvalidated: true)
    }
    
    func didRemoveActive(with basketType: BasketType) {        
        loadBudget()
        loadActives(finantialDataInvalidated: true)
    }
}

extension BalanceViewController {
    
    func showStatistics(with filterViewModel: SourceOrDestinationTransactionFilter) {
        push(factory.statisticsViewController(filter: filterViewModel))
    }
}
