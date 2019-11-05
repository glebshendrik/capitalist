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
                   source: TransactionSource,
                   destination: TransactionDestination)
}

class WaitingBorrowsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    private weak var delegate: WaitingBorrowsViewControllerDelegate? = nil
    private var borrowType: BorrowType = .debt
    
    var viewModel: WaitingBorrowsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var source: TransactionSource? = nil
    var destination: TransactionDestination? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func set(delegate: WaitingBorrowsViewControllerDelegate,
             source: TransactionSource,
             destination: TransactionDestination,
             waitingBorrows: [BorrowViewModel],
             borrowType: BorrowType) {
        self.delegate = delegate
        self.viewModel.set(borrowViewModels: waitingBorrows)
        self.source = source
        self.destination = destination
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
        guard let source = source,
            let destination = destination else {
                return
        }
        delegate?.didSelect(borrow: borrowViewModel,
                            source: source,
                            destination: destination)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
}
