//
//  WaitingDebtsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol WaitingBorrowsViewControllerDelegate : class {
    func didSelect(borrow: BorrowViewModel,
                   expenseSourceSource: ExpenseSourceViewModel,
                   expenseSourceDestination: ExpenseSourceViewModel)
}

class WaitingBorrowsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    private weak var delegate: WaitingBorrowsViewControllerDelegate? = nil
    private var borrowType: BorrowType = .debt
    
    var viewModel: WaitingBorrowsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var expenseSourceSource: ExpenseSourceViewModel? = nil
    var expenseSourceDestination: ExpenseSourceViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func set(delegate: WaitingBorrowsViewControllerDelegate,
             expenseSourceSource: ExpenseSourceViewModel,
             expenseSourceDestination: ExpenseSourceViewModel,
             waitingBorrows: [BorrowViewModel],
             borrowType: BorrowType) {
        self.delegate = delegate
        self.viewModel.set(borrowViewModels: waitingBorrows)
        self.expenseSourceSource = expenseSourceSource
        self.expenseSourceDestination = expenseSourceDestination
        self.borrowType = borrowType
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        headerTitleLabel.text = borrowType.title
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true)
    }
}

extension WaitingBorrowsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BorrowTableViewCell", for: indexPath) as? BorrowTableViewCell,
            let borrowViewModel = viewModel.borrowViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = borrowViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let borrowViewModel = viewModel.borrowViewModel(at: indexPath) else { return }
        close()
        guard let expenseSourceSource = expenseSourceSource,
            let expenseSourceDestination = expenseSourceDestination else {
                return
        }
        delegate?.didSelect(borrow: borrowViewModel,
                            expenseSourceSource: expenseSourceSource,
                            expenseSourceDestination: expenseSourceDestination)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
}
