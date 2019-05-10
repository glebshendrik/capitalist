//
//  BalanceLoadingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

extension BalanceViewController {
    
    @objc func loadData() {
        loadBudget()
        loadExpenseSources()
        loadExpenseCategories()
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
    
    private func loadExpenseCategories() {
        set(expenseCategoriesActivityIndicator, hidden: false, animated: false)
        firstly {
            viewModel.loadExpenseCategories()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки активов", theme: .error)
        }.finally {
            self.set(self.expenseCategoriesActivityIndicator, hidden: true)
            self.updateExpenseCategoriesUI()
        }
    }
}
