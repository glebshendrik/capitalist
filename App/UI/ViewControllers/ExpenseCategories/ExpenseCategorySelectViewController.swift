//
//  ExpenseCategorySelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit

protocol ExpenseCategorySelectViewControllerDelegate : class {
    func didSelect(expenseCategoryViewModel: ExpenseCategoryViewModel)
}

class ExpenseCategorySelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private weak var delegate: ExpenseCategorySelectViewControllerDelegate? = nil
    
    var viewModel: ExpenseCategoriesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func set(delegate: ExpenseCategorySelectViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func refreshData() {
        loadData()
    }
    
    func setActivityIndicator(hidden: Bool) {
        set(loader, hidden: hidden, animated: true)
    }
    
    private func loadData() {
        setActivityIndicator(hidden: false)
        firstly {
            viewModel.loadData()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки категорий трат", comment: "Ошибка загрузки категорий трат"), theme: .error)
            if self.delegate != nil {
                self.close()
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
        }
    }
    
    private func removeExpenseCategory(by id: Int, deleteTransactions: Bool) {
        setActivityIndicator(hidden: false)
        firstly {
            viewModel.removeExpenseCategory(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.refreshData()
        }
        .catch { error in
            self.setActivityIndicator(hidden: true)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка удаления категории трат", comment: "Ошибка удаления категории трат"), theme: .error)
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
    
    func showNewExpenseCategoryScreen() {
        showEditScreen(expenseCategory: nil, basketType: .joy)
    }
    
    func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType?) {
        modal(factory.expenseCategoryEditViewController(delegate: self, expenseCategory: expenseCategory, basketType: basketType ?? .joy))
    }
    
    func showExpenseCategoryInfoScreen(expenseCategory: ExpenseCategoryViewModel?) {
        modal(factory.expenseCategoryInfoViewController(expenseCategory: expenseCategory))
    }
}

extension ExpenseCategorySelectViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = viewModel.section(at: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .adding:
            return self.tableView(tableView, addingItemCellForRowAt: indexPath)
        case .items:
            return self.tableView(tableView, expenseCategoryCellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, addingItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddingItemTableViewCell", for: indexPath) as? AddingItemTableViewCell else {
                return UITableViewCell()
        }
        cell.addingTitleLabel.text = NSLocalizedString("Добавить категорию трат", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, expenseCategoryCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCategoryTableViewCell", for: indexPath) as? ExpenseCategoryTableViewCell,
            let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = expenseCategoryViewModel
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case .adding:
            showNewExpenseCategoryScreen()
        case .items:
            guard let expenseCategoryViewModel = viewModel.expenseCategoryViewModel(at: indexPath) else { return }
            if let delegate = delegate {
                closeButtonHandler() {
                    delegate.didSelect(expenseCategoryViewModel: expenseCategoryViewModel)
                }
            }
            else {
                showExpenseCategoryInfoScreen(expenseCategory: expenseCategoryViewModel)
            }
        }
    }
}

extension ExpenseCategorySelectViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        guard   orientation == .right,
                let expenseCategoryViewModel = self.viewModel.expenseCategoryViewModel(at: indexPath) else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, indexPath in
            let expenseCategoryViewModel = self.viewModel.expenseCategoryViewModel(at: indexPath)
            self.didTapDeleteButton(expenseCategoryViewModel: expenseCategoryViewModel)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "remove-icon")
        deleteAction.hidesWhenSelected = true
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Редактировать", comment: "")) { action, indexPath in
            let expenseCategoryViewModel = self.viewModel.expenseCategoryViewModel(at: indexPath)
            self.showEditScreen(expenseCategory: expenseCategoryViewModel?.expenseCategory, basketType: expenseCategoryViewModel?.basketType)
        }
        editAction.image = UIImage(named: "edit-info-icon")
        editAction.hidesWhenSelected = true
        
        return expenseCategoryViewModel.isCredit ? [editAction] : [deleteAction, editAction]
    }
    
    func didTapDeleteButton(expenseCategoryViewModel: ExpenseCategoryViewModel?) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let expenseCategoryId = expenseCategoryViewModel?.id {
            alertTitle = TransactionableType.expenseCategory.removeQuestion
            removeAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseCategory(by: expenseCategoryId, deleteTransactions: true)
            }
        }
        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                                      style: .destructive,
                                                      handler: removeAction),
                                        UIAlertAction(title: NSLocalizedString("Удалить вместе с транзакциями", comment: "Удалить вместе с транзакциями"),
                                                      style: .destructive,
                                                      handler: removeWithTransactionsAction)]
        sheet(title: alertTitle, actions: actions)
    }
    
    func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}

extension ExpenseCategorySelectViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        refreshData()
        postFinantialDataUpdated()
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        refreshData()
        postFinantialDataUpdated()
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        refreshData()
        postFinantialDataUpdated()
    }
}
