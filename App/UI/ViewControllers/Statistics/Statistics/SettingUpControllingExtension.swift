//
//  StatisticsSettingUpControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension StatisticsViewController {
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
                self.updateUI()
        }
    }
    
    func reloadFilterAndData() {
        postFinantialDataUpdated()
        setLoading()
        _ = firstly {
                viewModel.reloadFilterAndData()
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
            }.finally {
                self.updateUI()
        }
    }
    
    func reloadFilter() {        
        setLoading()
        _ = firstly {
                viewModel.reloadFilter()
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
            }.finally {
                self.updateUI()
        }
    }
    
    func removeTransaction(historyTransactionViewModel: HistoryTransactionViewModel) {
        setLoading()
        
        firstly {
            viewModel.removeTransaction(historyTransactionViewModel: historyTransactionViewModel)
        }.done {
            self.loadData(financialDataInvalidated: true)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления транзакции", theme: .error)
            self.updateUI()
        }
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setLoading() {
        viewModel.setDataLoading()
        updateUI()
    }
}

extension StatisticsViewController {
    func set(sourceOrDestinationFilter: SourceOrDestinationHistoryTransactionFilter) {
        viewModel.set(sourceOrDestinationFilter: sourceOrDestinationFilter)
    }
    
    func setupUI() {
        setupNavigationBar()
        setupFiltersUI()
        setupHistoryTransactionsUI()
        setupFooterOverlayUI()
    }
    
    func layoutSubviews() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: incomesContainer.frame.size.height, right: 0)
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
    
    private func setupFooterOverlayUI() {        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = footerOverlayView.bounds
        gradientLayer.colors = [
            UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 0.0).cgColor,
            UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 0.1).cgColor,
            UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1).cgColor
        ]
        
        footerOverlayView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension StatisticsViewController {
    func updateUI() {
        updateNavigationBar()
        updateFiltersUI()
        updateGraphFiltersSection()
        updateHistoryTransactionsUI()
        updateBalanceUI()        
    }
    
    func updateGraphFiltersSection() {        
        viewModel.updateGraphFiltersSection()
    }
    
    func updateGraphFilters(updateGraph: Bool = false) {
        updateGraphFiltersSection()
        if let graphFiltersSectionIndex = viewModel.graphFiltersSectionIndex {
            var indexSet = IndexSet(integer: graphFiltersSectionIndex)
            
            if  let graphSectionIndex = viewModel.graphSectionIndex,
                updateGraph {
                indexSet = IndexSet(arrayLiteral: graphSectionIndex, graphFiltersSectionIndex)
            }
            
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(indexSet, with: .none)                
            }
        }
    }
    
    private func updateNavigationBar() {
        titleView.dateRangeFilter = viewModel.dateRangeFilter
    }
    
    private func updateFiltersUI() {
        UIView.performWithoutAnimation {
            filtersCollectionView.reloadData()
            filtersCollectionView.performBatchUpdates(nil, completion: nil)
        }
        filtersHeightConstraint.constant = viewModel.hasSourceOrDestinationFilters ? 36.0 : 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHistoryTransactionsUI() {
        tableView.reloadData()
    }
    
    private func updateBalanceUI() {
        incomesContainer.isHidden = !viewModel.hasIncomeTransactions
        expensesContainer.isHidden = !viewModel.hasExpenseTransactions
        
        incomesAmountLabel.text = viewModel.filteredIncomesAmount
        expensesAmountLabel.text = viewModel.filteredExpensesAmount
    }
}
