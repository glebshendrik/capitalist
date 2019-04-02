//
//  StatisticsViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

class StatisticsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.navBarColor
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: StatisticsViewModel!
    
    private var titleView: StatisticsTitleView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    
    @IBOutlet weak var incomesContainer: UIView!
    @IBOutlet weak var expensesContainer: UIView!
    
    @IBOutlet weak var incomesAmountLabel: UILabel!
    @IBOutlet weak var expensesAmountLabel: UILabel!
    @IBOutlet weak var filtersHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.navBarColor
    }
    
    @IBAction func didTapFiltersSelectionButton(_ sender: Any) {
    }
    
}

// Show other screens and handle delegate calls
extension StatisticsViewController : IncomeEditViewControllerDelegate, ExpenseEditViewControllerDelegate, FundsMoveEditViewControllerDelegate {
    
    private func showFiltersSelectionView() {
        // TODO
    }
    
    private func showEdit(historyTransaction: HistoryTransactionViewModel) {
        // TODO
    }
    
    func didCreateIncome() {
    }
    
    func didUpdateIncome() {
        loadData()
    }
    
    func didRemoveIncome() {
        loadData()
    }
    
    func didCreateExpense() {
    }
    
    func didUpdateExpense() {
        loadData()
    }
    
    func didRemoveExpense() {
        loadData()
    }
    
    func didCreateFundsMove() {
    }
    
    func didUpdateFundsMove() {
        loadData()
    }
    
    func didRemoveFundsMove() {
        loadData()
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
                NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13)
            ])
        let edgeInsets = UIEdgeInsets(top: 5.0, left: 6.0, bottom: 3.0, right: 23.0)
        let size = CGSize(width: titleSize.width + edgeInsets.horizontal, height: 24.0)
        
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
        
        guard let section = viewModel.section(at: indexPath.section) else { return UITableViewCell() }
        
        func cell(for identifier: String) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        switch section {
        case is SourceOrDestinationFilterEditSection:
            guard let cell = cell(for: "StatisticsEditTableViewCell") as? StatisticsEditTableViewCell else { return UITableViewCell() }
            
            cell.editButtonTitleLabel.text = viewModel.editFilterTitle
            
            return cell
        case is GraphSection:
            return cell(for: "GraphTableViewCell")
        case is HistoryTransactionsLoadingSection:
            return cell(for: "HistoryTransactionsLoadingTableViewCell")
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
            return 145.0
        case is HistoryTransactionsLoadingSection:
            return 44.0
        case is HistoryTransactionsHeaderSection:
            return 44.0
        case is HistoryTransactionsSection:
            return 54.0
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }    
}

// Setups, Updates, Loaders
extension StatisticsViewController {
    
    func set(sourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter) {
        viewModel.set(sourceOrDestinationFilter: sourceOrDestinationFilter)
    }
    
    private func loadData() {
        setLoading()
        _ = firstly {
                viewModel.loadData()                
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
            }.finally {
                self.updateUI()
        }
    }
    
    private func setLoading() {
        viewModel.setDataLoading()
        updateUI()
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
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self        
    }
    
    private func setupHistoryTransactionsUI() {
        viewModel.updatePresentationData()
        tableView.delegate = self
        tableView.dataSource = self
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
        update(filtersCollectionView)
        filtersHeightConstraint.constant = viewModel.hasSourceOrDestinationFilters ? 36.0 : 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHistoryTransactionsUI() {
        tableView.reloadData()//(with: .automatic)
    }
    
    private func updateBalanceUI() {
        incomesContainer.isHidden = !viewModel.hasIncomeTransactions
        expensesContainer.isHidden = !viewModel.hasExpenseTransactions

        incomesAmountLabel.text = viewModel.filteredIncomesAmount
        expensesAmountLabel.text = viewModel.filteredExpensesAmount
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

