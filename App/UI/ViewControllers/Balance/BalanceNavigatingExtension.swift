//
//  BalanceNavigatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension BalanceViewController : BalanceExpenseSourcesTableSupportDelegate, BalanceActivesTableSupportDelegate {
    
    func didSelect(expenseSource: ExpenseSourceViewModel) {
        showStatistics(with: expenseSource.asTransactionFilter())
    }
    
    func didSelect(active: ActiveViewModel) {
//        showStatistics(with: expenseCategory.asIncludedInBalanceFilter())
    }
}

extension BalanceViewController {
    
    func showStatistics(with filterViewModel: SourceOrDestinationTransactionFilter) {
        if  let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController {
            
            statisticsViewController.set(sourceOrDestinationFilter: filterViewModel)
            
            navigationController?.pushViewController(statisticsViewController)
        }
    }
}
