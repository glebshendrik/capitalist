//
//  ActiveSelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit

protocol ActiveSelectViewControllerDelegate {
    func didSelect(sourceActiveViewModel: ActiveViewModel)
    func didSelect(destinationActiveViewModel: ActiveViewModel)
}

class ActiveSelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delegate: ActiveSelectViewControllerDelegate? = nil
    private var selectionType: TransactionPart = .destination
        
    var viewModel: ActivesViewModel!
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
    
    func set(delegate: ActiveSelectViewControllerDelegate,
             skipActiveId: Int?,
             selectionType: TransactionPart) {
        self.delegate = delegate
        self.viewModel.skipActiveId = skipActiveId
        self.selectionType = selectionType
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
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки активов", comment: "Ошибка загрузки активов"), theme: .error)
            if self.delegate != nil {
                self.close()
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
        }
    }
    
    private func removeActive(by id: Int, deleteTransactions: Bool) {
        setActivityIndicator(hidden: false)
        firstly {
            viewModel.removeActive(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.refreshData()
        }
        .catch { error in
            self.setActivityIndicator(hidden: true)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка удаления актива", comment: "Ошибка удаления актива"), theme: .error)
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
    
    func showNewActiveScreen() {
        let alertTitle = NSLocalizedString("Выберите тип актива", comment: "")
        
        let chooseSavingAction: ((UIAlertAction) -> Void)? = { _ in
            self.showNewActiveScreen(basketType: .safe)
        }
        let chooseInvestmentAction: ((UIAlertAction) -> Void)? = { _ in
            self.showNewActiveScreen(basketType: .risk)
        }
        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Сбережение", comment: ""),
                                                      style: .default,
                                                      handler: chooseSavingAction),
                                        UIAlertAction(title: NSLocalizedString("Инвестиция", comment: ""),
                                                      style: .default,
                                                      handler: chooseInvestmentAction)]
        sheet(title: alertTitle, actions: actions)
    }
    
    func showNewActiveScreen(basketType: BasketType) {
        showActiveEditScreen(active: nil, basketType: basketType)
    }
    
    func showActiveEditScreen(active: Active?, basketType: BasketType?) {
        guard let basketType = basketType else { return }
        modal(factory.activeEditViewController(delegate: self, active: active, basketType: basketType))
    }
    
    func showActiveInfo(active: ActiveViewModel) {
        modal(factory.activeInfoViewController(active: active))
    }
}

extension ActiveSelectViewController : UITableViewDelegate, UITableViewDataSource {
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
            return self.tableView(tableView, expenseSourceCellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, addingItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddingItemTableViewCell", for: indexPath) as? AddingItemTableViewCell else {
                return UITableViewCell()
        }
        cell.addingTitleLabel.text = NSLocalizedString("Добавить актив", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, expenseSourceCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell", for: indexPath) as? ActiveTableViewCell,
            let activeViewModel = viewModel.activeViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = activeViewModel
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case .adding:
            showNewActiveScreen()
        case .items:
            guard let activeViewModel = viewModel.activeViewModel(at: indexPath) else { return }
            if delegate != nil {
                didSelect(activeViewModel)
            }
            else {
                showActiveInfo(active: activeViewModel)
            }
        }
    }
    
    func didSelect(_ activeViewModel: ActiveViewModel) {
        switch selectionType {
        case .source:
            delegate?.didSelect(sourceActiveViewModel: activeViewModel)
        case .destination:
            delegate?.didSelect(destinationActiveViewModel: activeViewModel)
        }
        close()
    }
}

extension ActiveSelectViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        guard   orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, indexPath in
            let activeViewModel = self.viewModel.activeViewModel(at: indexPath)
            self.didTapDeleteButton(activeViewModel: activeViewModel)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "remove-icon")
        deleteAction.hidesWhenSelected = true
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Редактировать", comment: "")) { action, indexPath in
            let activeViewModel = self.viewModel.activeViewModel(at: indexPath)
            self.showActiveEditScreen(active: activeViewModel?.active, basketType: activeViewModel?.basketType)
        }
        editAction.image = UIImage(named: "edit-info-icon")
        editAction.hidesWhenSelected = true
        
        return [deleteAction, editAction]
    }
    
    func didTapDeleteButton(activeViewModel: ActiveViewModel?) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let activeId = activeViewModel?.id {
            alertTitle = TransactionableType.active.removeQuestion
            removeAction = { _ in
                self.removeActive(by: activeId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeActive(by: activeId, deleteTransactions: true)
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
}

extension ActiveSelectViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool) {
        refreshData()
    }
    
    func didUpdateActive(with basketType: BasketType) {
        refreshData()
    }
    
    func didRemoveActive(with basketType: BasketType) {
        refreshData()
    }
}
