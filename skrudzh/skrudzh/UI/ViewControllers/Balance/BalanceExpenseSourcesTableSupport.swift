//
//  BalanceExpenseSourcesTableSupport.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol BalanceExpenseSourcesTableSupportDelegate : class {
    func didSelect(expenseSource: ExpenseSourceViewModel)
}

class BalanceExpenseSourcesTableSupport : NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: BalanceViewModel
    private weak var delegate: BalanceExpenseSourcesTableSupportDelegate?
    
    init(viewModel: BalanceViewModel, delegate: BalanceExpenseSourcesTableSupportDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
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
        delegate?.didSelect(expenseSource: expenseSourceViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
