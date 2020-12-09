//
//  PrototypesLinkingViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 09.12.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class LinkingTransactionableViewModel {
    let transactionable: Transactionable
    
    var iconURL: URL? {
        return transactionable.iconURL
    }
    
    var defaultIconName: String {
        return transactionable.defaultIconName
    }
    
    var title: String {
        return transactionable.name
    }
    
    var isLinked: Bool {
        return transactionable.prototypeKey != nil
    }
    
    init(transactionable: Transactionable) {
        self.transactionable = transactionable
    }
}

class PrototypesLinkingViewModel {
    private let transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    var linkingType: TransactionableType = .incomeSource
    private var linkingTransactionables: [LinkingTransactionableViewModel] = []
    var linkingTransactionable: LinkingTransactionableViewModel?
    
    init(transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol,
         incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return
            firstly {
                loadTransactionables()
            }.get {
                self.linkingTransactionables = $0.map { LinkingTransactionableViewModel(transactionable: $0) }
                self.linkingTransactionable = nil
            }.asVoid()
    }
    
    func linkingTransactionable(by indexPath: IndexPath) -> LinkingTransactionableViewModel? {
        return linkingTransactionables[safe: indexPath.row]
    }
    
    func link(_ linkingTransactionable: LinkingTransactionableViewModel, prototypeKey: String) -> Promise<Void> {
        return Promise.value(())
    }
    
    func unlink(_ linkingTransactionable: LinkingTransactionableViewModel) -> Promise<Void> {
        return Promise.value(())
    }
    
    private func set(_ linkingTransactionable: LinkingTransactionableViewModel, prototypeKey: String?) -> Promise<Void> {
        switch linkingType {
            case .incomeSource:
                return loadIncomeSources()
            case .expenseSource:
                return loadExpenseSources()
            case .expenseCategory:
                return loadExpenseCategories()
            default:
                return Promise.value([])
        }
    }
    
    private func set(linkingIncomeSource: LinkingTransactionableViewModel, prototypeKey: String?) -> Promise<Void> {
        let linkingIncomeSource = (linkingIncomeSource.transactionable as? IncomeSourceViewModel)?.incomeSource
        return incomeSourcesCoordinator.update(with: IncomeSourceUpdatingForm(id: linkingIncomeSource., iconURL: <#T##URL?#>, name: <#T##String?#>, monthlyPlannedCents: <#T##Int?#>, description: <#T##String?#>, prototypeKey: <#T##String?#>, reminderAttributes: <#T##ReminderNestedAttributes?#>))
    }
    
    private func loadExpenseSources() -> Promise<[Transactionable]> {
        return
            firstly {
                expenseSourcesCoordinator.index(currency: nil)
            }.map {
                $0.map { ExpenseSourceViewModel(expenseSource: $0) }
            }
    }
    
    private func loadExpenseCategories() -> Promise<[Transactionable]> {
        return
            firstly {
                expenseCategoriesCoordinator.index(noBorrows: true)
            }.map {
                $0.map { ExpenseCategoryViewModel(expenseCategory: $0) }
            }
    }
    
}

extension PrototypesLinkingViewModel {
    private func loadTransactionables() -> Promise<[Transactionable]> {
        switch linkingType {
            case .incomeSource:
                return loadIncomeSources()
            case .expenseSource:
                return loadExpenseSources()
            case .expenseCategory:
                return loadExpenseCategories()
            default:
                return Promise.value([])
        }
    }
    
    private func loadIncomeSources() -> Promise<[Transactionable]> {
        return
            firstly {
                incomeSourcesCoordinator.index(noBorrows: true)
            }.map {
                $0.map { IncomeSourceViewModel(incomeSource: $0) }
            }
    }
    
    private func loadExpenseSources() -> Promise<[Transactionable]> {
        return
            firstly {
                expenseSourcesCoordinator.index(currency: nil)
            }.map {
                $0.map { ExpenseSourceViewModel(expenseSource: $0) }
            }
    }
    
    private func loadExpenseCategories() -> Promise<[Transactionable]> {
        return
            firstly {
                expenseCategoriesCoordinator.index(noBorrows: true)
            }.map {
                $0.map { ExpenseCategoryViewModel(expenseCategory: $0) }
            }
    }
}


