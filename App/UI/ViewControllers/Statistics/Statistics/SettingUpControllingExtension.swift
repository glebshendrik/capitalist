//
//  StatisticsSettingUpControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import BadgeHub
import EasyTipView

extension StatisticsViewController {
    func loadData(financialDataInvalidated: Bool = true) {
        if financialDataInvalidated {
            postFinantialDataUpdated()
        }
        refreshData()
    }
    
    func clearTransactions() {
        viewModel.clearTransactions()
        updateUI()
    }
    
    func loadTransactions(shouldClear: Bool = true) {
        if shouldClear {
            clearTransactions()
        }
        setLoading()
        _ = firstly {
                viewModel.loadTransactions()
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
            }.finally {
                self.updateUI()
                self.stopPullToRefresh()
            }
    }
    
    
    @objc func refreshData() {
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
    
    private func stopPullToRefresh() {
        tableView.es.stopPullToRefresh()
        tableView.refreshControl?.endRefreshing()
    }
}

extension StatisticsViewController {
    func set(filter: TransactionableFilter?) {
        viewModel.set(filter: filter)
    }
    
    func set(graphType: GraphType) {
        viewModel.set(graphType: graphType)
    }
    
    func setupUI() {
        setupNavigationBar()
        setupTableUI()
        setupPullToRefresh()
        setupNotifications()
    }
        
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupNavigationBar() {
        titleView = StatisticsTitleView(frame: CGRect.zero)
        titleView.delegate = self
        navigationItem.titleView = titleView
        
        setupNavigationBarAppearance()
        // TODO
        let filtersButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 26)))
        filtersButton.setImage(UIImage(named: "filters-icon"), for: .normal)
        filtersButton.addTarget(self, action: #selector(didTapFiltersButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filtersButton)
        setupFiltersBadgeUI()
    }
    
    private func setupFiltersBadgeUI() {
        if let badgeable = navigationItem.rightBarButtonItem?.customView {
            filtersBadge = BadgeHub(view: badgeable)
            filtersBadge?.setCircleColor(UIColor.by(.blue1), label: UIColor.by(.white100))
            filtersBadge?.scaleCircleSize(by: 0.6)
            filtersBadge?.setCountLabel(UIFont(name: "Roboto-Light", size: 12)!)
        }
    }
    
    @objc func didTapFiltersButton(_ sender: Any) {
        if viewModel.canShowFilters {
            showFilters()
        }
        else {            
            showSubscription()
        }
    }
    
    private func setupTableUI() {
        viewModel.updatePresentationData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TransactionsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: TransactionsSectionHeaderView.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100        
    }
    
    private func setupPullToRefresh() {
        tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadTransactions(shouldClear: false)
        }
        tableView.setupPullToRefreshAppearance()
    }
    
    func setMainOverlay(hidden: Bool, opacity: CGFloat = 0.8) {
        self.navigationController?.navigationBar.layer.zPosition = hidden ? 0 : -1
        self.navigationController?.navigationBar.isUserInteractionEnabled = hidden
        let newValue: CGFloat = hidden ? 0.0 : opacity
        UIView.animate(withDuration: 0.2, animations: {
            self.mainOverlay.alpha = newValue
        })
        view.haptic()
    }
}

extension StatisticsViewController {
    func updateUI() {
        updateNavigationBar()
        updateTableUI()
    }
    
    private func updateNavigationBar() {
        titleView.dateRangeFilter = viewModel.dateRangeFilter
        filtersBadge?.setCount(viewModel.numberOfTransactionableFilters)
        if viewModel.hasTransactionableFilters {
            filtersBadge?.pop()
        }
    }
    
    private func updateTableUI() {
        tableView.reloadData()
    }    
}

extension StatisticsViewController : EasyTipViewDelegate {
    var tutorials: [TutorialPayload] {        
        return [TutorialPayload(point: .statisticsFiltersTutorial,
                                message: NSLocalizedString("Гибкий фильтр отображения транзакций по источникам и назначениям", comment: ""),
                                anchor: navigationItem.rightBarButtonItem!,
                                position: .top,
                                offset: CGPoint(x: 15, y: 0),
                                inset: nil),
                TutorialPayload(point: .statisticsPeriodTutorial,
                                message: NSLocalizedString("Отображение статистики за выбранный период", comment: ""),
                                anchor: navigationItem.titleView!,
                                position: .top,
                                offset: nil,
                                inset: nil)]
    }
    
    func show(_ tutorials: [TutorialPayload]) {
        guard let tutorial = tutorials.first(where: { !UIFlowManager.reached(point: $0.point) }) else { return }
        
        setMainOverlay(hidden: false)
        tutorialTip = tip(tutorial.message,
                          position: tutorial.position,
                          offset: tutorial.offset,
                          inset: tutorial.inset,
                          for: tutorial.anchor,
                          within: nil,
                          delegate: self)
        UIFlowManager.set(point: tutorial.point, reached: true)
    }
            
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {        
        if tipView == tutorialTip {
            setMainOverlay(hidden: true)
            show(tutorials)
        }
    }
}
