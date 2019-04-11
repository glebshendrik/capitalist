//
//  StatisticsSectionsControllingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

extension StatisticsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = viewModel.section(at: section) else { return 0 }
        return section.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = viewModel.section(at: indexPath.section) else { return UITableViewCell() }
        
        func cell(for identifier: String) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            guard let cell = cell(for: "StatisticsEditTableViewCell") as? StatisticsEditTableViewCell else { return UITableViewCell() }
            
            cell.editButtonTitleLabel.text = viewModel.editFilterTitle
            cell.delegate = self
            
            return cell
        case is GraphSection:
            guard let cell = cell(for: "GraphTableViewCell") as? GraphTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self
            cell.viewModel = viewModel.graphViewModel
            
            return cell
        case is HistoryTransactionsLoadingSection:
            guard let cell = cell(for: "HistoryTransactionsLoadingTableViewCell") as? HistoryTransactionsLoadingTableViewCell else { return UITableViewCell() }
            
            cell.loaderImageView.showLoader()
            
            return cell
        case is HistoryTransactionsHeaderSection:
            return cell(for: "HistoryTransactionsHeaderTableViewCell")
        case is HistoryTransactionsSection:
            guard   let cell = cell(for: "HistoryTransactionTableViewCell") as? HistoryTransactionTableViewCell,
                let historyTransactionsSection = section as? HistoryTransactionsSection,
                let historyTransactionViewModel = historyTransactionsSection.historyTransactionViewModel(at: indexPath.row) else { return UITableViewCell() }
            
            cell.viewModel = historyTransactionViewModel
            
            return cell
        default:
            return UITableViewCell()
        }
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
        guard   let section = viewModel.section(at: indexPath.section),
                let historyTransactionsSection = section as? HistoryTransactionsSection,
                let historyTransactionViewModel = historyTransactionsSection.historyTransactionViewModel(at: indexPath.row) else { return }
        
        showEdit(historyTransaction: historyTransactionViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = viewModel.section(at: indexPath.section) else { return 0 }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            return 36.0
        case is GraphSection:
            return 370.0
        case is HistoryTransactionsLoadingSection:
            return 44.0
        case is HistoryTransactionsHeaderSection:
            return 44.0
        case is HistoryTransactionsSection:
            return 70.0
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }
}
