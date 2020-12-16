//
//  StatisticsSectionsControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension StatisticsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = viewModel.section(at: section) else { return 0 }
        return section.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch viewModel.section(at: indexPath.section) {
        case is GraphSection:
            return self.tableView(tableView, graphCellForRowAt: indexPath)
        case is GraphFiltersSection:
            return self.tableView(tableView, graphFiltersCellForRowAt: indexPath)
        case is TransactionsLoadingSection:
            return self.tableView(tableView, transactionsLoadingCellForRowAt: indexPath)
        case is TransactionsHeaderSection:
            return self.tableView(tableView, transactionsHeaderCellForRowAt: indexPath)
        case let transactionsSection as TransactionsSection:
            return self.tableView(tableView, section: transactionsSection, cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, graphCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GraphTableViewCell") as? GraphTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.viewModel = viewModel.graphViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, graphFiltersCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard   let cell = tableView.dequeueReusableCell(withIdentifier: "GraphFilterTableViewCell") as? GraphFilterTableViewCell,
                let filterViewModel = viewModel.graphFilterViewModel(at: indexPath.row) else { return UITableViewCell() }
        
        cell.viewModel = filterViewModel
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
    
    func tableView(_ tableView: UITableView, section: TransactionsSection, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard  let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? TransactionTableViewCell,
                let transactionViewModel = section.transactionViewModel(at: indexPath.row) else { return UITableViewCell() }
                   
        cell.viewModel = transactionViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = viewModel.section(at: indexPath.section) else {
            return false
        }        
        return section is TransactionsSection
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard   editingStyle == .delete,
                let section = viewModel.section(at: indexPath.section) as? TransactionsSection,
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
            let section = viewModel.section(at: section) as? TransactionsSection else { return nil }
        
        headerView.section = section
        headerView.contentView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard   let section = viewModel.section(at: section),
            section.isSectionHeaderVisible,
            section is TransactionsSection else { return CGFloat.leastNonzeroMagnitude }
        
        return TransactionsSectionHeaderView.requiredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case is GraphFiltersSection:
            guard let filterViewModel = viewModel.graphFilterViewModel(at: indexPath.row) else { return }
            
            if viewModel.canFilterTransactions(with: filterViewModel) {
                guard viewModel.canShowFilters else {
                    showSubscription()
                    return
                }
                viewModel.set(filter: filterViewModel)
            } else {
                viewModel.handleIncomeAndExpensesFilterTap(with: filterViewModel)
            }
            updateUI()
            
            return
        case let transactionsSection as TransactionsSection:
            guard let transactionViewModel = transactionsSection.transactionViewModel(at: indexPath.row) else { return }
            
            showEdit(transaction: transactionViewModel)
            return
        default:
            return
        }
    }
    
    
}
