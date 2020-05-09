//
//  IncomeSourcesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import ESPullToRefresh

class IncomeSourcesViewController : IncomeSourceSelectViewController {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSubtitleLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func setupUI() {
        super.setupUI()
        setupNotifications()
        setupPullToRefresh()
        setupTotalUI()
        setupNavigationBar()
        viewModel.noBorrows = false
    }
    
    override func updateUI() {
        super.updateUI()
        updateTotalUI()
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        set(editing: !tableView.isEditing)
    }
    
    @objc override func refreshData() {
        guard !viewModel.isUpdatingData else { return }
        tableView.es.startPullToRefresh()
    }
    
    override func setActivityIndicator(hidden: Bool) {
        self.viewModel.isUpdatingData = !hidden
        super.setActivityIndicator(hidden: hidden)
        if hidden {
            tableView.es.stopPullToRefresh()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupPullToRefresh() {
        tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadIncomeSources()
        }
        tableView.setupPullToRefreshAppearance()
    }
    
    private func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = "Источники дохода"
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
        
    private func setupTotalUI() {
        viewModel.shouldCalculateTotal = true
    }
    
    private func updateTotalUI() {
        UIView.transition(with: view,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
            self.totalLabel.text = self.viewModel.total
            self.totalSubtitleLabel.text = self.viewModel.totalSubtitle
        })
    }
        
    private func set(editing: Bool) {
        tableView.isEditing = editing
        editButton.image = UIImage.init(named: editing ? "save-icon" : "edit-info-icon")
        self.updateUI()
    }
    
    func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.moveIncomeSource(from: sourceIndexPath,
                                       to: destinationIndexPath)
        }.done {
//            self.updateUI()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка обновления порядка источников доходов", comment: "Ошибка обновления порядка источников доходов"), theme: .error)
        }.finally {
            self.set(self.loader, hidden: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension IncomeSourcesViewController {
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let section = viewModel.section(at: indexPath.section) else { return false }
        
        switch section {
        case .adding:
            return false
        case .items:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveIncomeSource(from: sourceIndexPath, to: destinationIndexPath)
    }
}
