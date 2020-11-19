//
//  StatisticsSectionsControllingExtension.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit

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
        case is ClearFiltersSection:
            return self.tableView(tableView, clearFiltersCellForRowAt: indexPath)
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
    
    func tableView(_ tableView: UITableView, clearFiltersCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClearFiltersTableViewCell") as? ClearFiltersTableViewCell else { return UITableViewCell() }
                
        cell.delegate = self
        cell.filtersNumber = viewModel.numberOfTransactionableFilters
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
        cell.delegate = self
        return cell
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

extension StatisticsViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
       
        guard   orientation == .right,
                let section = viewModel.section(at: indexPath.section) as? TransactionsSection,
                let transactionViewModel = section.transactionViewModel(at: indexPath.row)
        else {
            return nil
        }
        
        var actions = [SwipeAction]()
        
        if transactionViewModel.canDelete {
            let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Удалить", comment: "Удалить")) { action, indexPath in
                let transactionViewModel = section.transactionViewModel(at: indexPath.row)
                self.didTapDeleteButton(transactionViewModel: transactionViewModel)
            }
            // customize the action appearance
            deleteAction.image = UIImage(named: "remove-icon")
            deleteAction.hidesWhenSelected = true
            actions.append(deleteAction)
        }
                
        if transactionViewModel.canDuplicate {
            let duplicateAction = SwipeAction(style: .default, title: NSLocalizedString("Дубликат", comment: "")) { action, indexPath in
                let transactionViewModel = section.transactionViewModel(at: indexPath.row)
                self.didTapDuplicateButton(transactionViewModel: transactionViewModel)
            }
            // customize the action appearance
            duplicateAction.image = UIImage(named: "edit-info-icon")
            duplicateAction.hidesWhenSelected = true
            actions.append(duplicateAction)
        }
        
        return actions
    }
    
    func didTapDeleteButton(transactionViewModel: TransactionViewModel?) {
        guard   let transactionViewModel = transactionViewModel,
                transactionViewModel.canDelete else { return }
                        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                                      style: .destructive,
                                                      handler: { _ in
                                                        self.removeTransaction(transactionViewModel: transactionViewModel)
                                        })]
        sheet(title: transactionViewModel.removeTitle, actions: actions)
    }
    
    func didTapDuplicateButton(transactionViewModel: TransactionViewModel?) {
        guard   let transactionViewModel = transactionViewModel,
                transactionViewModel.canDuplicate else { return }
                        
        let actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("Дубликат", comment: ""),
                                                      style: .destructive,
                                                      handler: { _ in
                                                        self.duplicateTransaction(transactionViewModel: transactionViewModel)
                                        })]
        sheet(title: NSLocalizedString("Пометить транзакцию как дубликат", comment: ""), actions: actions)
    }
}
