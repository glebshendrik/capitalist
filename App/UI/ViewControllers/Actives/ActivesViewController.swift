//
//  ActivesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit

protocol ActivesViewControllerDelegate : class {
    func didSelect(sourceActiveViewModel: ActiveViewModel)
    func didSelect(destinationActiveViewModel: ActiveViewModel)
}

class ActivesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSubtitleLabel: UILabel!
    
    private weak var delegate: ActivesViewControllerDelegate? = nil
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
    
    func set(delegate: ActivesViewControllerDelegate,
             skipActiveId: Int?,
             selectionType: TransactionPart) {
        self.delegate = delegate
        self.viewModel.skipActiveId = skipActiveId
        self.selectionType = selectionType
    }
    
    @objc func refreshData() {
        loadData()
    }
    
    func setActivityIndicator(hidden: Bool) {        
        self.viewModel.isUpdatingData = !hidden
        set(loader, hidden: hidden, animated: true)
        if hidden {
            tableView.es.stopPullToRefresh()
            tableView.refreshControl?.endRefreshing()
        }
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
    
    private func setupUI() {
        setupNotifications()
        setupLoaderUI()
        setupTableViewUI()
        setupPullToRefresh()
        setupTotalUI()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTableViewUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLoaderUI() {
        loader.showLoader()
    }
    
    private func setupPullToRefresh() {
        tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadData()
        }
        tableView.setupPullToRefreshAppearance()
    }
            
    private func setupTotalUI() {
        
    }
    
    private func updateUI() {
        tableView.reloadData(with: .automatic)
        if viewModel.shouldCalculateTotal {
            updateTotalUI()
        }
    }
    
    private func updateTotalUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.totalLabel.text = self.viewModel.total
            self.totalSubtitleLabel.text = NSLocalizedString("Стоимость активов", comment: "")
        })
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
        modal(factory.activeEditViewController(delegate: self, active: active, basketType: basketType, costCents: nil))
    }
    
    func showActiveInfo(active: ActiveViewModel) {
        modal(factory.activeInfoViewController(active: active))
    }
}

extension ActivesViewController : UITableViewDelegate, UITableViewDataSource {
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
                closeButtonHandler() {
                    self.didSelect(activeViewModel)
                }
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
    }
}

extension ActivesViewController : SwipeTableViewCellDelegate {
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
        
        if let activeId = activeViewModel?.id {
            alertTitle = TransactionableType.active.removeQuestion
            removeAction = { _ in
                self.removeActive(by: activeId, deleteTransactions: false)
            }
        }
        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                                      style: .destructive,
                                                      handler: removeAction)]
        sheet(title: alertTitle, actions: actions)
    }
    
    func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}

extension ActivesViewController : ActiveEditViewControllerDelegate {
    func didCreateActive(with basketType: BasketType, name: String, isIncomePlanned: Bool) {
        refreshData()
        postFinantialDataUpdated()
    }
    
    func didUpdateActive(with basketType: BasketType) {
        refreshData()
        postFinantialDataUpdated()
    }
    
    func didRemoveActive(with basketType: BasketType) {
        refreshData()
        postFinantialDataUpdated()
    }
}
