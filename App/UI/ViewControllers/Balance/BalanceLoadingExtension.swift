//
//  BalanceLoadingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension BalanceViewController {
    
    @objc func loadData() {
        loadBudget()
        loadActives()
    }
    
    func loadBudget() {
        firstly {
            viewModel.loadBudget()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки баланса", comment: "Ошибка загрузки баланса"), theme: .error)
        }.finally {
            self.updateBalanceAmountsUI()
        }
    }
    
    func loadActives(finantialDataInvalidated: Bool = false) {
        if finantialDataInvalidated {
            postFinantialDataUpdated()
        }
        set(activesActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadActives()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки активов", comment: "Ошибка загрузки активов"), theme: .error)
        }.finally {
            self.set(self.activesActivityIndicator, hidden: true)
            self.updateActivesUI()
        }
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}
