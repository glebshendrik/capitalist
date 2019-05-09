//
//  BalanceViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 09/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

class BalanceViewController : UIViewController {
    @IBOutlet weak var expenseSourcesLabel: UILabel!
    @IBOutlet weak var expenseCategoriesLabel: UILabel!
    
    @IBOutlet weak var expenseSourcesSelectionIndicator: UIView!
    @IBOutlet weak var expenseCategoriesSelectionIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesActivityIndicator: UIView!
    @IBOutlet weak var expenseCategoriesActivityIndicator: UIView!
    
    @IBOutlet weak var expenseSourcesLoader: UIImageView!
    @IBOutlet weak var expenseCategoriesLoader: UIImageView!
    
    @IBOutlet weak var expenseSourcesContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var expenseCategoriesContainerLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var expenseSourcesTableView: UITableView!
    @IBOutlet weak var expenseCategoriesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    @IBAction func didTapExpenseSources(_ sender: Any) {
        
    }
    
    @IBAction func didTapExpenseCategories(_ sender: Any) {
        
    }
    
    private func setupUI() {
        
    }
    
    private func updateUI() {
        
    }
    
    private func updateBasketExpenseCategoriesContainer() {
        let lowPriority = UILayoutPriority(integerLiteral: 998)
        let highPriority = UILayoutPriority(integerLiteral: 999)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            
            self.joyExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isJoyBasketSelected ? highPriority : lowPriority
            self.riskExpenseCategoriesContainerLeftConstraint.priority = self.viewModel.basketsViewModel.isRiskBasketSelected ? highPriority : lowPriority
            self.safeExpenseCategoriesLeftConstraint.priority = self.viewModel.basketsViewModel.isSafeBasketSelected ? highPriority : lowPriority
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension BalanceViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfExpenseSources
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseSourceTableViewCell", for: indexPath) as? ExpenseSourceTableViewCell,
            let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = expenseSourceViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) else { return }
        switch selectionType {
        case .startable:
            delegate?.didSelect(startableExpenseSourceViewModel: expenseSourceViewModel)
        case .completable:
            delegate?.didSelect(completableExpenseSourceViewModel: expenseSourceViewModel)
        }
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension BalanceViewController {
    
    func didSelectExpenseSource(at indexPath: IndexPath) {
        if viewModel.isAddExpenseSourceItem(indexPath: indexPath) {
            showNewExpenseSourceScreen()
        } else if let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) {
            
            let filterViewModel = ExpenseSourceHistoryTransactionFilter(expenseSourceViewModel: expenseSourceViewModel)
            showStatistics(with: filterViewModel)
        }
    }
    
    func showStatistics(with filterViewModel: SourceOrDestinationHistoryTransactionFilter) {
        if  let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController {
            
            statisticsViewController.set(sourceOrDestinationFilter: filterViewModel)
            
            navigationController?.pushViewController(statisticsViewController)
        }
    }
}


