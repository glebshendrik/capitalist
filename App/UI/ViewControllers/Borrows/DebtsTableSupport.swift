//
//  DebtsTableSupport.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DebtsTableSupportDelegate : class {
    func didSelect(debt: BorrowViewModel)
}

class DebtsTableSupport : NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: BorrowsViewModel
    private weak var delegate: DebtsTableSupportDelegate?
    
    init(viewModel: BorrowsViewModel, delegate: DebtsTableSupportDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfDebts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BorrowTableViewCell", for: indexPath) as? BorrowTableViewCell,
            let debtViewModel = viewModel.debtViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = debtViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let debtViewModel = viewModel.debtViewModel(at: indexPath) else { return }
        delegate?.didSelect(debt: debtViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
}
