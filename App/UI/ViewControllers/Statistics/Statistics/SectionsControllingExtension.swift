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
        
        guard let section = viewModel.section(at: indexPath.section) else {
            return UITableViewCell()
        }
        
        func dequeueCell(for identifier: String) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            guard let cell = dequeueCell(for: "StatisticsEditTableViewCell") as? StatisticsEditTableViewCell else {
                return UITableViewCell()
                
            }
            
            cell.editButtonTitleLabel.text = viewModel.editFilterTitle
            cell.delegate = self
            
            return cell
        case is GraphSection:
            guard let cell = dequeueCell(for: "GraphTableViewCell") as? GraphTableViewCell else {
                return UITableViewCell()
                
            }
            
            cell.delegate = self
            cell.viewModel = viewModel.graphViewModel
            
            return cell
        case is GraphFiltersSection:
            guard let graphFiltersSection = section as? GraphFiltersSection,
                let cellType = graphFiltersSection.cellType(at: indexPath) else {
                    return UITableViewCell()
                    
            }
            
            let cell = dequeueCell(for: cellType.identifier)
            
            if let graphFiltersToggleCell = cell as? GraphFiltersToggleTableViewCell {
                graphFiltersToggleCell.delegate = self
                graphFiltersToggleCell.viewModel = viewModel.graphViewModel
                return graphFiltersToggleCell
            }
            
            if let graphTotalCell = cell as? GraphTotalTableViewCell {
                graphTotalCell.viewModel = viewModel.graphViewModel
                return graphTotalCell
            }
            
            if let graphFilterCell = cell as? GraphFilterTableViewCell,
                let filterViewModel = viewModel.graphFilterViewModel(at: graphFiltersSection.filterIndex(fromSectionIndexPath: indexPath) )  {
                graphFilterCell.viewModel = filterViewModel
                return graphFilterCell
            }
            
            return cell
        case is HistoryTransactionsLoadingSection:
            guard let cell = dequeueCell(for: "HistoryTransactionsLoadingTableViewCell") as? HistoryTransactionsLoadingTableViewCell else {
                return UITableViewCell()
                
            }
            
            cell.loaderImageView.showLoader()
            
            return cell
        case is HistoryTransactionsHeaderSection:            
            guard let cell = dequeueCell(for: "HistoryTransactionsHeaderTableViewCell") as? HistoryTransactionsHeaderTableViewCell else {
                return UITableViewCell()
                
            }
            
            cell.delegate = self
            
            return cell
        case is HistoryTransactionsSection:
            guard   let cell = dequeueCell(for: "HistoryTransactionTableViewCell") as? HistoryTransactionTableViewCell,
                let historyTransactionsSection = section as? HistoryTransactionsSection,
                let historyTransactionViewModel = historyTransactionsSection.historyTransactionViewModel(at: indexPath.row) else {
                    return UITableViewCell()
                    
            }
            
            cell.viewModel = historyTransactionViewModel
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = viewModel.section(at: indexPath.section) else {
            return false
        }        
        return section is HistoryTransactionsSection
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard   editingStyle == .delete,
                let section = viewModel.section(at: indexPath.section) as? HistoryTransactionsSection,
                let historyTransactionViewModel = section.historyTransactionViewModel(at: indexPath.row) else {
            return
        }
        askToDelete(historyTransactionViewModel: historyTransactionViewModel)
    }
    
    func askToDelete(historyTransactionViewModel: HistoryTransactionViewModel) {
        let alertController = UIAlertController(title: "Удалить транзакцию?",
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { [weak self] _ in
                                    self?.removeTransaction(historyTransactionViewModel: historyTransactionViewModel)
                                })
        
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard   let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryTransactionsSectionHeaderView.reuseIdentifier) as? HistoryTransactionsSectionHeaderView,
            let section = viewModel.section(at: section) as? HistoryTransactionsSection else { return nil }
        
        headerView.section = section
        headerView.contentView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 247.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard   let section = viewModel.section(at: section),
            section.isSectionHeaderVisible,
            section is HistoryTransactionsSection else { return CGFloat.leastNonzeroMagnitude }
        
        return HistoryTransactionsSectionHeaderView.requiredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = viewModel.section(at: indexPath.section) else { return }
        
        switch section {
        case let graphFiltersSection as GraphFiltersSection:
            guard let cellType = graphFiltersSection.cellType(at: indexPath),
                  cellType == .filter,
                  let filterViewModel = viewModel.graphFilterViewModel(at: graphFiltersSection.filterIndex(fromSectionIndexPath: indexPath) ),
                viewModel.areGraphFiltersInteractable else { return }
            
            if viewModel.canFilterTransactions(with: filterViewModel) {
                if !viewModel.singleSourceOrDestinationFilterEqualsTo(filter: filterViewModel) {
                    viewModel.set(sourceOrDestinationFilter: filterViewModel)
                    reloadFilter()
                }                
            } else {
                viewModel.handleIncomeAndExpensesFilterTap(with: filterViewModel)
                updateUI()
            }
            
            return
        case let historyTransactionsSection as HistoryTransactionsSection:
            guard let historyTransactionViewModel = historyTransactionsSection.historyTransactionViewModel(at: indexPath.row) else { return }
            
            showEdit(historyTransaction: historyTransactionViewModel)
            return
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = viewModel.section(at: indexPath.section) else { return 0 }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            return 36.0
        case is GraphSection:
            return 370.0
        case is GraphFiltersSection:
            return 44.0
        case is HistoryTransactionsLoadingSection:
            return 44.0
        case is HistoryTransactionsHeaderSection:
            return 92.0
        case is HistoryTransactionsSection:
            return 70.0
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
}
