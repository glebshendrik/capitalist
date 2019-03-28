//
//  StatisticsViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

class StatisticsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: StatisticsViewModel!
    
    private var titleView: StatisticsTitleView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
}

extension StatisticsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = viewModel.section(at: section) else { return 0 }
        return section.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard   let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryTransactionsSectionHeaderView.reuseIdentifier) as? HistoryTransactionsSectionHeaderView,
                let section = viewModel.section(at: section) as? HistoryTransactionsSection else { return nil }

        headerView.section = section

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard   let section = viewModel.section(at: section),
                section.isSectionHeaderVisible,
                section is HistoryTransactionsSection else { return CGFloat.leastNonzeroMagnitude }
        
        return HistoryTransactionsSectionHeaderView.requiredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// Setups, Updates, Loaders
extension StatisticsViewController {
    private func loadData() {
        _ = firstly {
                viewModel.loadData()                
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
            }.finally {
                self.updateUI()
        }
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupFiltersUI()
        setupHistoryTransactionsUI()
    }
    
    private func setupNavigationBar() {
        titleView = StatisticsTitleView(frame: CGRect.zero)
        navigationItem.titleView = titleView
    }
    
    private func setupFiltersUI() {
        
    }
    
    private func setupHistoryTransactionsUI() {
        viewModel.updatePresentationData()
        
        tableView.register(UINib(nibName: "HistoryTransactionsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: HistoryTransactionsSectionHeaderView.reuseIdentifier)
    }
    
    private func updateUI() {
        updateNavigationBar()
        updateFiltersUI()
        updateHistoryTransactionsUI()
        updateBalanceUI()
    }
    
    private func updateNavigationBar() {
        titleView.dateRangeFilter = viewModel.dateRangeFilter
    }
    
    private func updateFiltersUI() {
        
    }
    
    private func updateHistoryTransactionsUI() {
        
    }
    
    private func updateBalanceUI() {
        
    }
}
