//
//  BalanceExpenseCategoriesTableSupport.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol BalanceActivesTableSupportDelegate : class {
    func didSelect(active: ActiveViewModel)
}

class BalanceActivesTableSupport : NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: BalanceViewModel
    private weak var delegate: BalanceActivesTableSupportDelegate?
    
    init(viewModel: BalanceViewModel, delegate: BalanceActivesTableSupportDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfActives
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell", for: indexPath) as? ActiveTableViewCell,
            let activeViewModel = viewModel.activeViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = activeViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let activeViewModel = viewModel.activeViewModel(at: indexPath) else { return }
        delegate?.didSelect(active: activeViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
