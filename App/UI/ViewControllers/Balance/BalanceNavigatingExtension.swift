//
//  BalanceNavigatingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension BalanceViewController : BalanceExpenseSourcesTableSupportDelegate, BalanceExpenseCategoriesTableSupportDelegate {
    
    func didSelect(expenseSource: ExpenseSourceViewModel) {
        showStatistics(with: expenseSource.asHistoryTransactionFilter())
    }
    
    func didSelect(expenseCategory: ExpenseCategoryViewModel) {
        showStatistics(with: expenseCategory.asIncludedInBalanceFilter())
    }
}

extension BalanceViewController {
    
    func showStatistics(with filterViewModel: SourceOrDestinationHistoryTransactionFilter) {
        if  let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController {
            
            statisticsViewController.set(sourceOrDestinationFilter: filterViewModel)
            
            navigationController?.pushViewController(statisticsViewController)
        }
    }
}
