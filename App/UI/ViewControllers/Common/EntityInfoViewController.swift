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
class RefreshHeaderAnimator : ESRefreshHeaderAnimator {
    
}
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
        loadData(financialDataInvalidated: false)
    }
        
    func setupUI() {
        viewModel.updatePresentationData()
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]        
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = UIColor.by(.textFFFFFF)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-circle-icon"), style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "edit-info-icon"), style: .plain, target: self, action: #selector(didTapEditButton(sender:)))
        
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
            self?.loadData()
        }
        tableView.es.addInfiniteScrolling {
            [weak self] in
            self?.loadMore()
        }
        tableView.es.noticeNoMoreData()
        tableView.es.stopLoadingMore()        
    }
    
    func updateUI() {
        tableView.reloadData()
        updateNavigationBarUI()
    }
    
    func updateNavigationBarUI() {
        navigationItem.title = viewModel.title
    }
    
    @objc func didTapCloseButton(sender: Any) {
        entityInfoNavigationController?.close()
    }
    
    @objc func didTapEditButton(sender: Any) {
        entityInfoNavigationController?.showEditScreen()
    }
}

extension EntityInfoViewController {
    func loadData(financialDataInvalidated: Bool = true) {
        if financialDataInvalidated {
            postFinantialDataUpdated()
        }
        setLoading()
        _ = firstly {
                viewModel.loadData()
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
            }.finally {
                self.stopLoading()
                self.updateUI()
        }
    }
    
    func loadMore() {
        let lastTransaction = viewModel.lastTransaction
        
        _ = firstly {
                viewModel.loadMoreTransactions()
            }.ensure {
                if !self.viewModel.hasMoreData {
                    self.tableView.es.noticeNoMoreData()
                }
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                
                if let indexPath = self.viewModel.indexPath(for: lastTransaction) {
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
                }
                self.tableView.es.stopLoadingMore()
            }
    }
    
    func saveData(financialDataInvalidated: Bool = true) {
        setLoading()
        _ = firstly {
                viewModel.save()
            }.done {
                if financialDataInvalidated {
                    self.postFinantialDataUpdated()
                }
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка сохранения данных", theme: .error)
            }.finally {
                self.stopLoading()
                self.updateUI()
            }
    }
    
    func removeTransaction(transactionViewModel: TransactionViewModel) {
        setLoading()
        
        firstly {
            viewModel.removeTransaction(transactionViewModel: transactionViewModel)
        }.done {
            self.postFinantialDataUpdated()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления транзакции", theme: .error)
        }.finally {
            self.stopLoading()
            self.updateUI()
        }
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setLoading() {
        viewModel.setDataLoading()
        tableView.es.startPullToRefresh()
        updateUI()
    }
    
    private func stopLoading() {
        tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
        tableView.es.resetNoMoreData()
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
         guard  let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? EntityTransactionTableViewCell,
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
        let alertController = UIAlertController(title: "Удалить транзакцию?",
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { [weak self] _ in
                                    self?.removeTransaction(transactionViewModel: transactionViewModel)
                                })
        
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard   let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TransactionsSectionHeaderView.reuseIdentifier) as? TransactionsSectionHeaderView,
            let section = viewModel.section(at: section) as? EntityInfoTransactionsSection else { return nil }
        
        headerView.title = section.title
        headerView.contentView.backgroundColor = UIColor.by(.dark2A314B)
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
            guard let reminderField = entityFieldsSection.infoField(at: indexPath.row) as? ReminderInfoField else { return }
            
            entityInfoNavigationController?.didTapReminderButton(field: reminderField)
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
            showBorrowEditScreen(borrowId: borrowId, borrowType: borrowType)
        }
        else if let creditId = transaction.creditId {
            showCreditEditScreen(creditId: creditId)
        }
        else {
            showTransactionEditScreen(transactionId: transaction.id)
        }
    }
    
    private func showTransactionEditScreen(transactionId: Int) {
        modal(factory.transactionEditViewController(delegate: self, transactionId: transactionId))
    }
        
    private func showBorrowEditScreen(borrowId: Int, borrowType: BorrowType) {
        modal(factory.borrowEditViewController(delegate: self, type: borrowType, borrowId: borrowId, source: nil, destination: nil))
    }
    
    private func showCreditEditScreen(creditId: Int) {
        modal(factory.creditEditViewController(delegate: self, creditId: creditId, destination: nil))
    }
}

extension EntityInfoViewController : TransactionEditViewControllerDelegate, BorrowEditViewControllerDelegate, CreditEditViewControllerDelegate {
    
    func didCreateCredit() {
        
    }
    
    func didCreateDebt() {
        
    }
    
    func didCreateLoan() {
        
    }
    
    func didUpdateCredit() {
        loadData()
    }
    
    func didRemoveCredit() {
        loadData()
    }
    
    func didUpdateDebt() {
        loadData()
    }
    
    func didUpdateLoan() {
        loadData()
    }
    
    func didRemoveDebt() {
        loadData()
    }
    
    func didRemoveLoan() {
        loadData()
    }
    
    func didCreateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didUpdateTransaction(id: Int, type: TransactionType) {
        loadData()
    }
    
    func didRemoveTransaction(id: Int, type: TransactionType) {
        loadData()
    }
}
