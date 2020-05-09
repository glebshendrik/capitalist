//
//  ExpenseSourcesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 09.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit
import ESPullToRefresh

protocol ExpenseSourcesViewControllerDelegate {
    func didSelect(sourceExpenseSourceViewModel: ExpenseSourceViewModel)
    func didSelect(destinationExpenseSourceViewModel: ExpenseSourceViewModel)
}

extension UIScrollView {
    var refreshControlHeaderTitleLabel: UILabel? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.titleLabel
    }
    
    var refreshControlHeaderImageView: UIImageView? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.imageView
    }
    
    var refreshControlHeaderIndicatorView: UIActivityIndicatorView? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.indicatorView
    }
    
    var refreshControlFooterTitleLabel: UILabel? {
        return (footer?.animator as? ESRefreshFooterAnimator)?.titleLabel
    }
        
    var refreshControlFooterIndicatorView: UIActivityIndicatorView? {
        return (footer?.animator as? ESRefreshFooterAnimator)?.indicatorView
    }
    
    func setupPullToRefreshAppearance() {
        refreshControlHeaderTitleLabel?.textColor = UIColor.by(.white64)
        refreshControlHeaderIndicatorView?.color = UIColor.by(.white64)
        refreshControlHeaderImageView?.tintColor = UIColor.by(.white64)
        refreshControlHeaderTitleLabel?.font = UIFont(name: "Roboto-Light", size: 13)
        refreshControlFooterTitleLabel?.textColor = UIColor.by(.white64)
        refreshControlFooterIndicatorView?.color = UIColor.by(.white64)        
        refreshControlFooterTitleLabel?.font = UIFont(name: "Roboto-Light", size: 13)
        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl?.tintColor = .clear
    }
}

extension ESRefreshHeaderAnimator {
    var titleLabel: UILabel? {
        return self.view.subviews.first { $0 is UILabel } as? UILabel
    }
    
    var imageView: UIImageView? {
        return self.view.subviews.first { $0 is UIImageView } as? UIImageView
    }
    
    var indicatorView: UIActivityIndicatorView? {
        return self.view.subviews.first { $0 is UIActivityIndicatorView } as? UIActivityIndicatorView
    }
}

extension ESRefreshFooterAnimator {
    var titleLabel: UILabel? {
        return self.view.subviews.first { $0 is UILabel } as? UILabel
    }
        
    var indicatorView: UIActivityIndicatorView? {
        return self.view.subviews.first { $0 is UIActivityIndicatorView } as? UIActivityIndicatorView
    }
}

class ExpenseSourcesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSubtitleLabel: UILabel!
    
    private var delegate: ExpenseSourcesViewControllerDelegate? = nil
    private var selectionType: TransactionPart = .destination
    
    var viewModel: ExpenseSourcesViewModel!
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
    
    func set(delegate: ExpenseSourcesViewControllerDelegate,
             skipExpenseSourceId: Int?,
             selectionType: TransactionPart,
             currency: String?) {
        self.delegate = delegate
        self.viewModel.skipExpenseSourceId = skipExpenseSourceId
        self.viewModel.currencyFilter = currency
        self.selectionType = selectionType
    }
    
    func refreshData() {
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
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки кошельков", comment: "Ошибка загрузки кошельков"), theme: .error)
            if self.delegate != nil {
                self.close()
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
        }
    }
    
    private func removeExpenseSource(by id: Int, deleteTransactions: Bool) {
        setActivityIndicator(hidden: false)
        firstly {
            viewModel.removeExpenseSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseSource()
        }
        .catch { error in
            self.setActivityIndicator(hidden: true)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка удаления кошелька", comment: "Ошибка удаления кошелька"), theme: .error)
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        setupLoaderUI()
        setupTableViewUI()
        setupPullToRefresh()
        setupTotalUI()
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
            self.totalSubtitleLabel.text = ""
        })
    }
    
    func showNewExpenseSourceScreen() {
        showEditScreen(expenseSource: nil)
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource))
    }
    
    func showExpenseSourceInfoScreen(expenseSource: ExpenseSourceViewModel?) {
        modal(factory.expenseSourceInfoViewController(expenseSource: expenseSource))
    }
}

extension ExpenseSourcesViewController : UITableViewDelegate, UITableViewDataSource {
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
        cell.addingTitleLabel.text = NSLocalizedString("Добавить кошелек", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, expenseSourceCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseSourceTableViewCell", for: indexPath) as? ExpenseSourceTableViewCell,
            let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = expenseSourceViewModel
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case .adding:
            showNewExpenseSourceScreen()
        case .items:
            guard let expenseSourceViewModel = viewModel.expenseSourceViewModel(at: indexPath) else { return }
            if delegate != nil {
                didSelect(expenseSourceViewModel)
            }
            else {
                showExpenseSourceInfoScreen(expenseSource: expenseSourceViewModel)
            }
        }
    }
    
    func didSelect(_ expenseSourceViewModel: ExpenseSourceViewModel) {
        switch selectionType {
        case .source:
            delegate?.didSelect(sourceExpenseSourceViewModel: expenseSourceViewModel)
        case .destination:
            delegate?.didSelect(destinationExpenseSourceViewModel: expenseSourceViewModel)
        }
        close()
    }
}

extension ExpenseSourcesViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        guard   orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, indexPath in
            let expenseSourceViewModel = self.viewModel.expenseSourceViewModel(at: indexPath)
            self.didTapDeleteButton(expenseSourceViewModel: expenseSourceViewModel)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "remove-icon")
        deleteAction.hidesWhenSelected = true
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Редактировать", comment: "")) { action, indexPath in
            let expenseSourceViewModel = self.viewModel.expenseSourceViewModel(at: indexPath)
            self.showEditScreen(expenseSource: expenseSourceViewModel?.expenseSource)
        }
        editAction.image = UIImage(named: "edit-info-icon")
        editAction.hidesWhenSelected = true
        
        return [deleteAction, editAction]
    }
    
    func didTapDeleteButton(expenseSourceViewModel: ExpenseSourceViewModel?) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        var removeWithTransactionsAction: ((UIAlertAction) -> Void)? = nil
        
        if let expenseSourceId = expenseSourceViewModel?.id {
            alertTitle = TransactionableType.expenseSource.removeQuestion
            removeAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: false)
            }
            removeWithTransactionsAction = { _ in
                self.removeExpenseSource(by: expenseSourceId, deleteTransactions: true)
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

extension ExpenseSourcesViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        refreshData()
    }
    
    func didUpdateExpenseSource() {
        refreshData()
    }
    
    func didRemoveExpenseSource() {
        refreshData()
    }
}
