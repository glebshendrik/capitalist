//
//  BalanceSettingUpExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

extension BalanceViewController {
    
    func select(_ balanceCategory: BalanceCategory) {
        viewModel.selectedBalanceCategory = balanceCategory
        updateTabsUI()
        updateBalanceCategoryUI()
    }
    
    func setupUI() {
        setupTables()
        setupLoaders()
        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTables() {
        expenseSourcesSupport = BalanceExpenseSourcesTableSupport(viewModel: viewModel, delegate: self)
        expenseCategoriesSupport = BalanceExpenseCategoriesTableSupport(viewModel: viewModel, delegate: self)
        
        expenseSourcesTableView.dataSource = expenseSourcesSupport
        expenseSourcesTableView.delegate = expenseSourcesSupport
        
        expenseCategoriesTableView.dataSource = expenseCategoriesSupport
        expenseCategoriesTableView.delegate = expenseCategoriesSupport
        
        expenseSourcesTableView.tableFooterView = UIView()
        expenseCategoriesTableView.tableFooterView = UIView()
    }
    
    private func setupLoaders() {
        expenseSourcesLoader.showLoader()
        expenseCategoriesLoader.showLoader()
    }
    
    func updateUI() {
        updateTabsUI()
        updateBalanceCategoryUI()
        updateBalanceAmountsUI()
        updateExpenseSourcesUI()
        updateExpenseCategoriesUI()
    }
    
    func updateBalanceAmountsUI() {
        expenseSourcesAmountLabel.text = viewModel.budgetViewModel?.expenseSourcesBalance
        expenseCategoriesAmountLabel.text = viewModel.budgetViewModel?.includedInBalanceExpenses
    }
    
    func updateExpenseSourcesUI() {
        expenseSourcesTableView.reloadData(with: .automatic)
    }
    
    func updateExpenseCategoriesUI() {
        expenseCategoriesTableView.reloadData(with: .automatic)
    }
    
    func updateTabsUI() {
        
        func tabsAppearances(for balanceCategory: BalanceCategory) -> (expenseSources: TabAppearance, expenseCategories: TabAppearance) {
            
            let selectedColor = UIColor.by(.textFFFFFF)
            let unselectedColor = UIColor.by(.text9EAACC)
            
            let selectedTabAppearance: TabAppearance = (textColor: selectedColor, isHidden: false)
            let unselectedTabAppearance: TabAppearance = (textColor: unselectedColor, isHidden: true)
            
            switch balanceCategory {
            case .expenseSources:
                return (expenseSources: selectedTabAppearance,
                        expenseCategories: unselectedTabAppearance)
            case .expenseCategories:
                return (expenseSources: unselectedTabAppearance,
                        expenseCategories: selectedTabAppearance)
            }
        }
        
        let tabsAppearance = tabsAppearances(for: viewModel.selectedBalanceCategory)
        
        expenseSourcesLabel.textColor = tabsAppearance.expenseSources.textColor
        expenseCategoriesLabel.textColor = tabsAppearance.expenseCategories.textColor
        
        expenseSourcesSelectionIndicator.isHidden = tabsAppearance.expenseSources.isHidden
        expenseCategoriesSelectionIndicator.isHidden = tabsAppearance.expenseCategories.isHidden
    }
    
    func updateBalanceCategoryUI() {
        
        func layoutPriorities(by balanceCategory: BalanceCategory) -> (expenseSourcesPriority: UILayoutPriority, expenseCategoriesPriority: UILayoutPriority) {
            
            let low = UILayoutPriority(integerLiteral: 998)
            let high = UILayoutPriority(integerLiteral: 999)
            
            switch balanceCategory {
            case .expenseSources:
                return (expenseSourcesPriority: high, expenseCategoriesPriority: low)
            case .expenseCategories:
                return (expenseSourcesPriority: low, expenseCategoriesPriority: high)
            }
        }
        
        let priorities = layoutPriorities(by: viewModel.selectedBalanceCategory)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.expenseSourcesContainerLeftConstraint.priority = priorities.expenseSourcesPriority
            self.expenseCategoriesContainerLeftConstraint.priority = priorities.expenseCategoriesPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
