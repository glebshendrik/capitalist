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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
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
        
    }
    
    private func setupFiltersUI() {
        
    }
    
    private func setupHistoryTransactionsUI() {
        viewModel.updatePresentationData()
    }
    
    private func updateUI() {
        updateNavigationBar()
        updateFiltersUI()
        updateHistoryTransactionsUI()
        updateBalanceUI()
    }
    
    private func updateNavigationBar() {
        
    }
    
    private func updateFiltersUI() {
        
    }
    
    private func updateHistoryTransactionsUI() {
        
    }
    
    private func updateBalanceUI() {
        
    }
}
