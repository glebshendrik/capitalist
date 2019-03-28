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

// Show Other Screens
extension StatisticsViewController {
    private func showFiltersSelectionView() {
        
    }
    
    private func showEdit(historyTransaction: HistoryTransactionViewModel) {
        
    }
}

extension MainViewController: IncomeEditViewControllerDelegate {
    func didCreateIncome() {
        soundsManager.playTransactionCompletedSound()
        updateIncomeDependentData()
    }
    
    func didUpdateIncome() {
        updateIncomeDependentData()
    }
    
    func didRemoveIncome() {
        updateIncomeDependentData()
    }
    
    private func updateIncomeDependentData() {
        loadIncomeSources()
        loadBudget()
        loadBaskets()
        loadExpenseSources()
    }
}

extension MainViewController: ExpenseEditViewControllerDelegate {
    func didCreateExpense() {
        soundsManager.playTransactionCompletedSound()
        updateExpenseDependentData()
    }
    
    func didUpdateExpense() {
        updateExpenseDependentData()
    }
    
    func didRemoveExpense() {
        updateExpenseDependentData()
    }
    
    private func updateExpenseDependentData() {
        loadBudget()
        loadBaskets()
        loadExpenseSources()
        loadExpenseCategories(by: .joy)
        loadExpenseCategories(by: .risk)
        loadExpenseCategories(by: .safe)
    }
}

extension MainViewController: FundsMoveEditViewControllerDelegate {
    func didCreateFundsMove() {
        soundsManager.playTransactionCompletedSound()
        updateFundsMoveDependentData()
    }
    
    func didUpdateFundsMove() {
        updateFundsMoveDependentData()
    }
    
    func didRemoveFundsMove() {
        updateFundsMoveDependentData()
    }
    
    private func updateFundsMoveDependentData() {
        loadExpenseSources()
    }
}

// Filters
extension StatisticsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSourceOrDestinationFilters
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell,
            let filter = viewModel.sourceOrDestinationFilter(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.viewModel = filter
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let filter = viewModel.sourceOrDestinationFilter(at: indexPath) else {
            return CGSize.zero
        }
        
        let titleSize = filter.title.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)
            ])
        let edgeInsets = UIEdgeInsets(top: 5.0, left: 6.0, bottom: 3.0, right: 13.0)
        let size = CGSize(width: titleSize.width + edgeInsets.horizontal, height: titleSize.height + edgeInsets.vertical)
        
        return size
    }
    
}

// Statistics Sections
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
        guard   let section = viewModel.section(at: indexPath.section),
                let historyTransactionsSection = section as? HistoryTransactionsSection,
                let historyTransactionViewModel = historyTransactionsSection.historyTransactionViewModel(at: indexPath.row) else { return }
        
        showEdit(historyTransaction: historyTransactionViewModel)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = viewModel.section(at: indexPath.section) else { return 0 }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            return 50.0
        case is GraphSection:
            return 145.0
        case is HistoryTransactionsLoadingSection:
            return 50.0
        case is HistoryTransactionsHeaderSection:
            return 40.0
        case is HistoryTransactionsSection:
            return 54.0
        default:
            return CGFloat.leastNonzeroMagnitude
        }
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
        titleView.delegate = self
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

// FilterCellDelegate
extension StatisticsViewController : FilterCellDelegate {
    func didTapDeleteButton(filter: SourceOrDestinationHistoryTransactionFilter) {
        viewModel.remove(sourceOrDestinationFilter: filter)
        updateUI()
    }
}

// StatisticsTitleViewDelegate
extension StatisticsViewController : StatisticsTitleViewDelegate {
    func didTapRemoveDateRangeButton() {
        viewModel.removeDateRangeFilter()
        updateUI()
    }
}

