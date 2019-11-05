//
//  ExpenseSourceSelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseSourceSelectViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel)
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel)
}

class ExpenseSourceSelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delegate: ExpenseSourceSelectViewControllerDelegate? = nil
    private var selectionType: TransactionPart = .destination
    
    var viewModel: ExpenseSourcesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadExpenseSources()
    }
    
    func set(delegate: ExpenseSourceSelectViewControllerDelegate,
             skipExpenseSourceId: Int?,
             selectionType: TransactionPart,
             currency: String?) {
        self.delegate = delegate
        self.viewModel.skipExpenseSourceId = skipExpenseSourceId
        self.viewModel.currency = currency
        self.selectionType = selectionType
    }
    
    private func loadExpenseSources() {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.loadExpenseSources()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки кошельков", theme: .error)
            self.close()
        }.finally {
            self.set(self.loader, hidden: true)
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() {
        tableView.reloadData(with: .automatic)
    }
    
    private func setupUI() {
        loader.showLoader()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ExpenseSourceSelectViewController : UITableViewDelegate, UITableViewDataSource {
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
        case .source:
            delegate?.didSelect(sourceExpenseSourceViewModel: expenseSourceViewModel)
        case .destination:
            delegate?.didSelect(destinationExpenseSourceViewModel: expenseSourceViewModel)
        }
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
