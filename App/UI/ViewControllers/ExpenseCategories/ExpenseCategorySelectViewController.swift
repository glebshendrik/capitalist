//
//  ExpenseCategorySelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ExpenseCategorySelectViewControllerDelegate {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel)
}

class ExpenseCategorySelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delegate: ExpenseCategorySelectViewControllerDelegate? = nil
    
    var viewModel: ExpenseCategoriesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadExpenseCategories()
    }
    
    func set(delegate: ExpenseCategorySelectViewControllerDelegate) {
        self.delegate = delegate
    }
    
    private func loadExpenseCategories() {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.loadExpenseCategories()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки категорий трат", comment: "Ошибка загрузки категорий трат"), theme: .error)
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

extension ExpenseCategorySelectViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfExpenseCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCategoryTableViewCell", for: indexPath) as? ExpenseCategoryTableViewCell,
            let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = expenseCategoryViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else { return }
        delegate?.didSelect(expenseCategoryViewModel: expenseCategoryViewModel)
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
