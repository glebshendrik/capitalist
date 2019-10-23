//
//  DataControllingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension MainViewController {
    func loadData() {
        loadBudget()
        loadIncomeSources()
        loadExpenseSources()
        loadBaskets()
        loadExpenseCategories(by: .joy)
        loadActives(by: .risk)
        loadActives(by: .safe)
    }
    
    private func show(errors: [String: String]) {
        for (_, validationMessage) in errors {
            messagePresenterManager.show(validationMessage: validationMessage)
        }
    }
}

extension MainViewController {
    func loadBudget() {
        firstly {
            viewModel.loadBudget()
        }.done {
            self.updateBudgetUI()
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки баланса", theme: .error)
        }.finally {
                
        }
    }
}

extension MainViewController {
    func loadBaskets() {
        firstly {
            viewModel.loadBaskets()
        }.done {
            self.updateBasketsUI()
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки корзин", theme: .error)
        }.finally {
        }
    }
}

extension MainViewController {
    func loadIncomeSources(scrollToEndWhenUpdated: Bool = false) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadIncomeSources()
        }.done {
            self.update(self.incomeSourcesCollectionView,
                        scrollToEnd: scrollToEndWhenUpdated)
        }
        .catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников доходов", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
    
    func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.moveIncomeSource(from: sourceIndexPath,
                                       to: destinationIndexPath)
        }.done {
            self.update(self.incomeSourcesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка источников доходов", theme: .error)
        }.finally {
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
        }
    }
    
    func removeIncomeSource(by id: Int, deleteTransactions: Bool) {
        set(incomeSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeIncomeSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveIncomeSource()
        }
        .catch { error in
            self.set(self.incomeSourcesActivityIndicator, hidden: true)
            switch error {
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка удаления источника дохода", theme: .error)
            }
        }
    }
}

extension MainViewController {
    func loadExpenseSources(scrollToEndWhenUpdated: Bool = false) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadExpenseSources()
        }.done {
            self.update(self.expenseSourcesCollectionView,
                        scrollToEnd: scrollToEndWhenUpdated)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников трат", theme: .error)
        }.finally {
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
        }
    }
    
    func moveExpenseSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.moveExpenseSource(from: sourceIndexPath,
                                        to: destinationIndexPath)
        }.done {
            self.update(self.expenseSourcesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка кошельков", theme: .error)
        }.finally {
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
        }
    }
    
    func removeExpenseSource(by id: Int, deleteTransactions: Bool) {
        set(expenseSourcesActivityIndicator, hidden: false)
        firstly {
            viewModel.removeExpenseSource(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseSource()
        }
        .catch { error in
            self.set(self.expenseSourcesActivityIndicator, hidden: true)
            switch error {
            case APIRequestError.unprocessedEntity(let errors):
                self.show(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: "Ошибка удаления кошелька", theme: .error)
            }
        }
    }
}

extension MainViewController {
    func loadExpenseCategories(by basketType: BasketType, scrollToEndWhenUpdated: Bool = false) {
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.loadExpenseCategories()
        }.done {
            self.update(self.joyExpenseCategoriesCollectionView,
                        scrollToEnd: scrollToEndWhenUpdated)
            self.updateBasketsItemsPageControl(by: basketType)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки категорий трат", theme: .error)
        }.finally {
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    func moveExpenseCategory(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, basketType: BasketType) {
        
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {            
            viewModel.moveJoyExpenseCategory(from: sourceIndexPath,
                                             to: destinationIndexPath)
        }.done {
            self.update(self.joyExpenseCategoriesCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка категорий трат", theme: .error)
        }.finally {
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    func removeExpenseCategory(by id: Int, basketType: BasketType, deleteTransactions: Bool) {
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.removeExpenseCategory(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseCategory(with: basketType)
        }
        .catch { _ in
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления категории трат", theme: .error)
        }
    }
}

extension MainViewController {
    func loadActives(by basketType: BasketType, scrollToEndWhenUpdated: Bool = false) {
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.loadActives(by: basketType)
        }.done {
            self.update(self.basketItemsCollectionView(by: basketType),
                        scrollToEnd: scrollToEndWhenUpdated)
            self.updateBasketsItemsPageControl(by: basketType)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки активов", theme: .error)
        }.finally {
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    func moveActive(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, basketType: BasketType) {
        
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.moveActive(from: sourceIndexPath,
                                 to: destinationIndexPath,
                                 basketType: basketType)
        }.done {
            self.update(self.basketItemsCollectionView(by: basketType))
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка обновления порядка активов", theme: .error)
        }.finally {
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
        }
    }
    
    func removeActive(by id: Int, basketType: BasketType, deleteTransactions: Bool) {
        set(basketItemsActivityIndicator(by: basketType), hidden: false)
        firstly {
            viewModel.removeActive(by: id, deleteTransactions: deleteTransactions)
        }.done {
            self.didRemoveExpenseCategory(with: basketType)
        }
        .catch { _ in
            self.set(self.basketItemsActivityIndicator(by: basketType), hidden: true)
            self.messagePresenterManager.show(navBarMessage: "Ошибка удаления актива", theme: .error)
        }
    }
}

