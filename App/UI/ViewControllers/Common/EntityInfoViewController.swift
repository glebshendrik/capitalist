//
//  EntityInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import ESPullToRefresh

class EntityInfoViewController : UIViewController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol {
        
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: EntityInfoViewModel!
    
    var entityInfoNavigationController : EntityInfoNavigationController? {
        return navigationController as? EntityInfoNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshData()
    }
          
    func setupUI() {
        viewModel.updatePresentationData()
        setupNavigationBar()
        setupTableView()
        setupNotifications()
    }
    
    func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit-info-icon"), style: .plain, target: self, action: #selector(didTapEditButton(sender:)))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.by(.blue1)
        updateNavigationBarUI()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "TransactionsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: TransactionsSectionHeaderView.reuseIdentifier)
        tableView.es.addPullToRefresh {
            [weak self] in
            self?.updateData()
        }
        tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.loadMoreTransactions()
        }
        tableView.es.noticeNoMoreData()
        tableView.es.stopLoadingMore()
        tableView.setupPullToRefreshAppearance()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    func updateUI() {
        tableView.reloadData()
        updateNavigationBarUI()
    }
    
    func updateNavigationBarUI() {
        navigationItem.title = viewModel.title
    }
        
    @objc func didTapEditButton(sender: Any) {
        entityInfoNavigationController?.showEditScreen()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EntityInfoViewController {
    @objc func refreshData() {
        guard !viewModel.isUpdatingData else { return }
        tableView.es.startPullToRefresh()
    }
    
    private func updateData() {
        setLoading()
        _ = firstly {
                viewModel.updateData()
            }.catch { e in
                print(e)
                if case APIRequestError.notFound = e {                    
                    self.closeButtonHandler()
                }
                else {
                    self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка обновления данных", comment: "Ошибка обновления данных"), theme: .error)
                }
            }.finally {
                self.stopLoading()
                self.updateUI()
            }
    }
    
    private func loadMoreTransactions() {
        let lastTransaction = viewModel.lastTransaction
        
        _ = firstly {
                viewModel.loadMoreTransactions()
            }.catch{ _ in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
            }.finally {                
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                
                if let indexPath = self.viewModel.indexPath(for: lastTransaction) {
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
                self.tableView.es.stopLoadingMore()
                if !self.viewModel.hasMoreData {
                    self.tableView.es.noticeNoMoreData()
                }
            }
    }
    
    func saveData() {
        viewModel.needToSaveData = true
        refreshData()
    }
    
    func removeTransaction(transactionViewModel: TransactionViewModel) {
        viewModel.transactionToDelete = transactionViewModel
        refreshData()
    }
    
    private func setLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func stopLoading() {
        tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        tableView.es.resetNoMoreData()
        tableView.refreshControl?.endRefreshing()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension EntityInfoViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = viewModel.section(at: section) else { return 0 }
        return section.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch viewModel.section(at: indexPath.section) {
        case let entityInfoSection as EntityInfoFieldsSection:
            return self.tableView(tableView, section: entityInfoSection, cellForRowAt: indexPath)
        case is EntityInfoTransactionsLoadingSection:
            return self.tableView(tableView, transactionsLoadingCellForRowAt: indexPath)
        case is EntityInfoTransactionsHeaderSection:
            return self.tableView(tableView, transactionsHeaderCellForRowAt: indexPath)
        case let transactionsSection as EntityInfoTransactionsSection:            
            return self.tableView(tableView, section: transactionsSection, cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, section: EntityInfoFieldsSection, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard   let field = section.infoField(at: indexPath.row),
                let cell = tableView.dequeueReusableCell(withIdentifier: field.cellIdentifier) as? EntityInfoTableViewCell else { return UITableViewCell() }
        
        cell.delegate = entityInfoNavigationController
        cell.field = field
        return cell
    }
    
    func tableView(_ tableView: UITableView, transactionsLoadingCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsLoadingTableViewCell") as? TransactionsLoadingTableViewCell else { return UITableViewCell() }

        cell.loaderImageView.showLoader()
        return cell
    }
    
    func tableView(_ tableView: UITableView, transactionsHeaderCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TransactionsHeaderTableViewCell") ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, section: EntityInfoTransactionsSection, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard  let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? TransactionTableViewCell,
                let transactionViewModel = section.transactionViewModel(at: indexPath.row) else { return UITableViewCell() }
                   
        cell.viewModel = transactionViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = viewModel.section(at: indexPath.section) else {
            return false
        }
        return section is EntityInfoTransactionsSection
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard   editingStyle == .delete,
                let section = viewModel.section(at: indexPath.section) as? EntityInfoTransactionsSection,
                let transactionViewModel = section.transactionViewModel(at: indexPath.row) else {
            return
        }
        askToDelete(transactionViewModel: transactionViewModel)
    }
    
    func askToDelete(transactionViewModel: TransactionViewModel) {
        let alertController = UIAlertController(title: transactionViewModel.removeTitle,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { [weak self] _ in
                                    self?.removeTransaction(transactionViewModel: transactionViewModel)
                                })
        
        
        alertController.addAction(title: NSLocalizedString("Отмена", comment: "Отмена"),
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard   let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TransactionsSectionHeaderView.reuseIdentifier) as? TransactionsSectionHeaderView,
            let section = viewModel.section(at: section) as? EntityInfoTransactionsSection else { return nil }
        
        headerView.title = section.title
        headerView.contentView.backgroundColor = UIColor.by(.white40)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard   let section = viewModel.section(at: section),
            section.isSectionHeaderVisible,
            section is EntityInfoTransactionsSection else { return CGFloat.leastNonzeroMagnitude }
        
        return TransactionsSectionHeaderView.requiredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case let entityFieldsSection as EntityInfoFieldsSection:
            if let reminderField = entityFieldsSection.infoField(at: indexPath.row) as? ReminderInfoField {
                entityInfoNavigationController?.didTapReminderButton(field: reminderField)
            }
            else if let basicField = entityFieldsSection.infoField(at: indexPath.row) as? BasicInfoField {
                entityInfoNavigationController?.didTapInfoField(field: basicField)
            }
            return
        case let transactionsSection as EntityInfoTransactionsSection:
            guard let transactionViewModel = transactionsSection.transactionViewModel(at: indexPath.row) else { return }
            
            showEdit(transaction: transactionViewModel)
            return
        default:
            return
        }
    }
}

extension EntityInfoViewController {
    func showEdit(transaction: TransactionViewModel) {
        if let borrowId = transaction.borrowId, let borrowType = transaction.borrowType {
            showBorrowInfoScreen(borrowId: borrowId, borrowType: borrowType)
        }
        else if let creditId = transaction.creditId {
            showCreditInfoScreen(creditId: creditId)
        }
        else {
            showTransactionEditScreen(transactionId: transaction.id)
        }
    }
    
    private func showTransactionEditScreen(transactionId: Int) {
        modal(factory.transactionEditViewController(delegate: self, transactionId: transactionId))
    }
        
    func showBorrowInfoScreen(borrowId: Int, borrowType: BorrowType) {
        modal(factory.borrowInfoViewController(borrowId: borrowId, borrowType: borrowType, borrow: nil))
    }
        
    private func showCreditInfoScreen(creditId: Int) {
        modal(factory.creditInfoViewController(creditId: creditId, credit: nil))
    }
}

extension EntityInfoViewController : TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
    
    var isSelectingTransactionables: Bool {
        return false
    }
    
    func didCreateCredit() {

    }

    func didCreateDebt() {

    }

    func didCreateLoan() {

    }

    func didUpdateCredit() {
        postFinantialDataUpdated()
    }

    func didRemoveCredit() {
        postFinantialDataUpdated()
    }

    func didUpdateDebt() {
        postFinantialDataUpdated()
    }

    func didUpdateLoan() {
        postFinantialDataUpdated()
    }

    func didRemoveDebt() {
        postFinantialDataUpdated()
    }

    func didRemoveLoan() {
        postFinantialDataUpdated()
    }

    func didCreateTransaction(id: Int, type: TransactionType) {
        postFinantialDataUpdated()
    }

    func didUpdateTransaction(id: Int, type: TransactionType) {
        postFinantialDataUpdated()
    }

    func didRemoveTransaction(id: Int, type: TransactionType) {
        postFinantialDataUpdated()
    }
    
    func shouldShowCreditEditScreen(destination: TransactionDestination) {
        showCreditEditScreen(destination: destination)
    }

    func shouldShowBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        showBorrowEditScreen(type: type, source: source, destination: destination)
    }
    
    func showBorrowEditScreen(type: BorrowType, source: TransactionSource, destination: TransactionDestination) {
        modal(factory.borrowEditViewController(delegate: self,
                                               type: type,
                                               borrowId: nil,
                                               source: source,
                                               destination: destination))
    }
    
    func showCreditEditScreen(destination: TransactionDestination) {
        modal(factory.creditEditViewController(delegate: self,
                                               creditId: nil,
                                               destination: destination))
    }
}
