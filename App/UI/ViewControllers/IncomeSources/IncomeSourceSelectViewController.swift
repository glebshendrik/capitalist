//
//  IncomeSourceSelectViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit

protocol IncomeSourceSelectViewControllerDelegate : class {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel)
}

class IncomeSourceSelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private weak var delegate: IncomeSourceSelectViewControllerDelegate? = nil
    
    var viewModel: IncomeSourcesViewModel!
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
    
    func set(delegate: IncomeSourceSelectViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func refreshData() {
        loadIncomeSources()
    }
    
    func setActivityIndicator(hidden: Bool) {
        set(loader, hidden: hidden, animated: true)
    }
    
    func loadIncomeSources() {
        setActivityIndicator(hidden: false)
        firstly {
            viewModel.loadData()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки источников доходов", comment: "Ошибка загрузки источников доходов"), theme: .error)
            if self.delegate != nil {
                self.close()
            }
        }.finally {
            self.setActivityIndicator(hidden: true)
        }
    }
    
    private func removeIncomeSource(by id: Int, deleteTransactions: Bool) {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.removeIncomeSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveIncomeSource()
        }
        .catch { error in
            self.set(self.loader, hidden: true)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка удаления источника дохода", comment: "Ошибка удаления источника дохода"), theme: .error)
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func updateUI() {
        tableView.reloadData(with: .automatic)
    }
    
    func setupUI() {
        loader.showLoader()
        tableView.delegate = self
        tableView.dataSource = self
    }
               
    func showNewIncomeSourceScreen() {
        showEditScreen(incomeSource: nil)
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
    }
    
    func showIncomeSourceInfoScreen(incomeSource: IncomeSourceViewModel?) {
        modal(factory.incomeSourceInfoViewController(incomeSource: incomeSource))
    }
}

extension IncomeSourceSelectViewController : UITableViewDelegate, UITableViewDataSource {
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
            return self.tableView(tableView, incomeSourceCellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, addingItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddingItemTableViewCell", for: indexPath) as? AddingItemTableViewCell else {
                return UITableViewCell()
        }
        cell.addingTitleLabel.text = NSLocalizedString("Добавить источник дохода", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, incomeSourceCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeSourceTableViewCell", for: indexPath) as? IncomeSourceTableViewCell,
            let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = incomeSourceViewModel
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case .adding:
            showNewIncomeSourceScreen()
        case .items:
            guard let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else { return }
            if let delegate = delegate {                
                closeButtonHandler() {
                    delegate.didSelect(incomeSourceViewModel: incomeSourceViewModel)
                }
            }
            else {
                showIncomeSourceInfoScreen(incomeSource: incomeSourceViewModel)
            }            
        }
    }
}

extension IncomeSourceSelectViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        guard   orientation == .right,
                let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, indexPath in
            let incomeSourceViewModel = self.viewModel.incomeSourceViewModel(at: indexPath)
            self.didTapDeleteButton(incomeSourceViewModel: incomeSourceViewModel)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "remove-icon")
        deleteAction.hidesWhenSelected = true
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Редактировать", comment: "")) { action, indexPath in
            let incomeSourceViewModel = self.viewModel.incomeSourceViewModel(at: indexPath)
            self.showEditScreen(incomeSource: incomeSourceViewModel?.incomeSource)
        }
        editAction.image = UIImage(named: "edit-info-icon")
        editAction.hidesWhenSelected = true
        
        return incomeSourceViewModel.isChild ? [editAction] : [deleteAction, editAction]        
    }
    
    func didTapDeleteButton(incomeSourceViewModel: IncomeSourceViewModel?) {
        var alertTitle = ""
        var removeAction: ((UIAlertAction) -> Void)? = nil
        
        if let incomeSourceId = incomeSourceViewModel?.id {
            alertTitle = TransactionableType.incomeSource.removeQuestion
            removeAction = { _ in
                self.removeIncomeSource(by: incomeSourceId, deleteTransactions: false)
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

extension IncomeSourceSelectViewController : IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource() {
        postFinantialDataUpdated()
        refreshData()
    }
    
    func didUpdateIncomeSource() {
        postFinantialDataUpdated()
        refreshData()
    }
    
    func didRemoveIncomeSource() {
        postFinantialDataUpdated()
        refreshData()
    }
}
