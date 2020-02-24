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
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
            }.finally {
                self.updateUI()
        }
    }
    
    func removeTransaction(transactionViewModel: TransactionViewModel) {
        setLoading()
        
        firstly {
            viewModel.removeTransaction(transactionViewModel: transactionViewModel)
        }.done {
            self.loadData(financialDataInvalidated: true)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка удаления транзакции", comment: "Ошибка удаления транзакции"), theme: .error)
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
    func set(filter: TransactionableFilter?) {
        viewModel.set(filter: filter)
    }
    
    func setupUI() {
        setupNavigationBar()
        setupTableUI()
    }
        
    private func setupNavigationBar() {
        titleView = StatisticsTitleView(frame: CGRect.zero)
        titleView.delegate = self
        navigationItem.titleView = titleView
        
        setupNavigationBarAppearance()
        // TODO
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filters-icon"), style: .plain, target: self, action: #selector(didTapFiltersButton(_:)))
    }
    
    @objc func didTapFiltersButton(_ sender: Any) {
        showFilters()
    }
            
    private func setupTableUI() {
        viewModel.updatePresentationData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TransactionsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: TransactionsSectionHeaderView.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100        
    }
}

extension StatisticsViewController {
    func updateUI() {
        updateNavigationBar()
        updateTableUI()
    }
    
    private func updateNavigationBar() {
        titleView.dateRangeFilter = viewModel.dateRangeFilter
        navigationItem.rightBarButtonItem?.image = UIImage(named: viewModel.hasTransactionableFilters ? "filters-dot-icon" : "filters-icon")        
    }
    
    private func updateTableUI() {
        tableView.reloadData()
    }    
}

//        func reloadFilterAndData() {
//            postFinantialDataUpdated()
//            setLoading()
//            _ = firstly {
//                    viewModel.reloadFilterAndData()
//                }.catch { _ in
//                    self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
//                }.finally {
//                    self.updateUI()
//            }
//        }
    
//    func reloadFilter() {
//        setLoading()
//        _ = firstly {
//                viewModel.reloadFilter()
//            }.catch { _ in
//                self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки данных", theme: .error)
//            }.finally {
//                self.updateUI()
//        }
//    }
//func updateGraphFiltersSection() {
//    viewModel.updateGraphFiltersSection()
//}
//
//func updateGraphFilters(updateGraph: Bool = false) {
//    updateGraphFiltersSection()
//    if let graphFiltersSectionIndex = viewModel.graphFiltersSectionIndex {
//        var indexSet = IndexSet(integer: graphFiltersSectionIndex)
//        
//        if  let graphSectionIndex = viewModel.graphSectionIndex,
//            updateGraph {
//            indexSet = IndexSet(arrayLiteral: graphSectionIndex, graphFiltersSectionIndex)
//        }
//        
//        UIView.performWithoutAnimation {
//            self.tableView.reloadSections(indexSet, with: .none)
//        }
//    }
//}
