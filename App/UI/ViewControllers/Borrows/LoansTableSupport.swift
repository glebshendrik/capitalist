//
//  LoansTableSupport.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol LoansTableSupportDelegate : class {
    func didSelect(loan: BorrowViewModel)
}

class LoansTableSupport : NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: BorrowsViewModel
    private weak var delegate: LoansTableSupportDelegate?
    
    init(viewModel: BorrowsViewModel, delegate: LoansTableSupportDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLoans
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BorrowTableViewCell", for: indexPath) as? BorrowTableViewCell,
            let loanViewModel = viewModel.loanViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = loanViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let loanViewModel = viewModel.loanViewModel(at: indexPath) else { return }
        delegate?.didSelect(loan: loanViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
}
