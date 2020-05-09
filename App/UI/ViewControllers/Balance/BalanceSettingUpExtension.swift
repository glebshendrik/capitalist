//
//  BalanceSettingUpExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import BetterSegmentedControl

extension BalanceViewController {
    
    func select(_ balanceCategory: BalanceCategory) {
        viewModel.selectedBalanceCategory = balanceCategory
        updateBalanceCategoryUI()
    }
    
    func setupUI() {
        setupNavigationBar()
        setupBalanceTabs()
        setupTables()
        setupLoaders()        
        setupNotifications()
    }
    
    private func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Баланс", comment: "Баланс")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus-icon"), style: .plain, target: self, action: #selector(didTapAddButton(sender:)))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.by(.blue1)
    }
    
    @objc func didTapAddButton(sender: Any) {
        switch viewModel.selectedBalanceCategory {
        case .expenseSources:
            expenseSourcesViewController.showNewExpenseSourceScreen()
        default:
            return
        }
    }
    
    func setupBalanceTabs() {
        guard !tabsInitialized else { return }
        tabs.segments = LabelSegment.segments(withTitles: [NSLocalizedString("КОШЕЛЬКИ", comment: "КОШЕЛЬКИ"),
                                                           NSLocalizedString("АКТИВЫ", comment: "АКТИВЫ")],
                                              normalBackgroundColor: UIColor.clear,
                                              normalFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              normalTextColor: UIColor.by(.white100),
                                              selectedBackgroundColor: UIColor.by(.white12),
                                              selectedFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              selectedTextColor: UIColor.by(.white100))
        tabs.addTarget(self, action: #selector(didChangeBalanceTab(_:)), for: .valueChanged)
        tabsInitialized = true
    }
    
    @objc func didChangeBalanceTab(_ sender: Any) {
        switch tabs.index {
        case 0:
            select(.expenseSources)
        case 1:
            select(.actives)
        default:
            return
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTables() {
        activesSupport = BalanceActivesTableSupport(viewModel: viewModel, delegate: self)
                
        activesTableView.dataSource = activesSupport
        activesTableView.delegate = activesSupport
        
        activesTableView.tableFooterView = UIView()
    }
    
    private func setupLoaders() {
        activesLoader.showLoader()
    }
    
    func updateUI() {
        updateBalanceCategoryUI()
        updateBalanceAmountsUI()
        updateActivesUI()
    }
    
    func updateBalanceAmountsUI() {
        activesAmountLabel.text = viewModel.budgetViewModel?.activesAmountRounded
    }
        
    func updateActivesUI() {
        activesTableView.reloadData(with: .automatic)
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
