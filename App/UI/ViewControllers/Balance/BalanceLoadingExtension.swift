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
        loadExpenseSources()
        loadActives()
    }
    
    private func loadBudget() {
        firstly {
            viewModel.loadBudget()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки баланса", theme: .error)
        }.finally {
            self.updateBalanceAmountsUI()
        }
    }
    
    private func loadExpenseSources() {
        set(expenseSourcesActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadExpenseSources()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки кошельков", theme: .error)
        }.finally {
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
            self.updateExpenseSourcesUI()
        }
    }
    
    private func loadActives() {
        set(activesActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadActives()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки активов", theme: .error)
        }.finally {
            self.set(self.activesActivityIndicator, hidden: true)
            self.updateActivesUI()
        }
    }
}
