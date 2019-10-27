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
        activesSupport = BalanceActivesTableSupport(viewModel: viewModel, delegate: self)
        
        expenseSourcesTableView.dataSource = expenseSourcesSupport
        expenseSourcesTableView.delegate = expenseSourcesSupport
        
        activesTableView.dataSource = activesSupport
        activesTableView.delegate = activesSupport
        
        expenseSourcesTableView.tableFooterView = UIView()
        activesTableView.tableFooterView = UIView()
    }
    
    private func setupLoaders() {
        expenseSourcesLoader.showLoader()
        activesLoader.showLoader()
    }
    
    func updateUI() {
        updateTabsUI()
        updateBalanceCategoryUI()
        updateBalanceAmountsUI()
        updateExpenseSourcesUI()
        updateActivesUI()
    }
    
    func updateBalanceAmountsUI() {
        expenseSourcesAmountLabel.text = viewModel.budgetViewModel?.expenseSourcesAmountRounded
        activesAmountLabel.text = viewModel.budgetViewModel?.activesAmountRounded
    }
    
    func updateExpenseSourcesUI() {
        expenseSourcesTableView.reloadData(with: .automatic)
    }
    
    func updateActivesUI() {
        activesTableView.reloadData(with: .automatic)
    }
    
    func updateTabsUI() {
                
        func tabsAppearances(for balanceCategory: BalanceCategory) -> (expenseSources: TabAppearance, actives: TabAppearance) {
            
            let selectedColor = UIColor.by(.textFFFFFF)
            let unselectedColor = UIColor.by(.text9EAACC)
            
            let selectedTabAppearance: TabAppearance = (textColor: selectedColor, isHidden: false)
            let unselectedTabAppearance: TabAppearance = (textColor: unselectedColor, isHidden: true)
            
            switch balanceCategory {
            case .expenseSources:
                return (expenseSources: selectedTabAppearance,
                        actives: unselectedTabAppearance)
            case .actives:
                return (expenseSources: unselectedTabAppearance,
                        actives: selectedTabAppearance)
            }
        }
        
        let tabsAppearance = tabsAppearances(for: viewModel.selectedBalanceCategory)
        
        expenseSourcesLabel.textColor = tabsAppearance.expenseSources.textColor
        activesLabel.textColor = tabsAppearance.actives.textColor
        
        expenseSourcesSelectionIndicator.isHidden = tabsAppearance.expenseSources.isHidden
        activesSelectionIndicator.isHidden = tabsAppearance.actives.isHidden
    }
    
    func updateBalanceCategoryUI() {
        
        func layoutPriorities(by balanceCategory: BalanceCategory) -> (expenseSourcesPriority: UILayoutPriority, activesPriority: UILayoutPriority) {
            
            let low = UILayoutPriority(integerLiteral: 998)
            let high = UILayoutPriority(integerLiteral: 999)
            
            switch balanceCategory {
            case .expenseSources:
                return (expenseSourcesPriority: high, activesPriority: low)
            case .actives:
                return (expenseSourcesPriority: low, activesPriority: high)
            }
        }
        
        let priorities = layoutPriorities(by: viewModel.selectedBalanceCategory)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.expenseSourcesContainerLeftConstraint.priority = priorities.expenseSourcesPriority
            self.activesContainerLeftConstraint.priority = priorities.activesPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
