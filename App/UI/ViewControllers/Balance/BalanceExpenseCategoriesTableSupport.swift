//
//  BalanceExpenseCategoriesTableSupport.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol BalanceExpenseCategoriesTableSupportDelegate : class {
    func didSelect(expenseCategory: ExpenseCategoryViewModel)
}

class BalanceExpenseCategoriesTableSupport : NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: BalanceViewModel
    private weak var delegate: BalanceExpenseCategoriesTableSupportDelegate?
    
    init(viewModel: BalanceViewModel, delegate: BalanceExpenseCategoriesTableSupportDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfExpenseCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveExpenseCategoryTableViewCell", for: indexPath) as? ActiveExpenseCategoryTableViewCell,
            let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = expenseCategoryViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else { return }
        delegate?.didSelect(expenseCategory: expenseCategoryViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
