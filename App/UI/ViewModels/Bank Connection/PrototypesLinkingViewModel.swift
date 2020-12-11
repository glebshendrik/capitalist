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
    
    var linkButtonTitle: String {
        return isLinked
            ? NSLocalizedString("Отвязать", comment: "")
            : NSLocalizedString("Связать", comment: "")
    }
    
    var linkButtonColorAsset: ColorAsset {
        return isLinked
            ? .white4
            : .blue1
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
    var linkingTransactionable: LinkingTransactionableViewModel? = nil
    
    var numberOfLinkingTransactionables: Int {
        return linkingTransactionables.count
    }
    
    var title: String? {
        switch linkingType {
            case .incomeSource:
                return NSLocalizedString("Связывание источников доходов", comment: "")
            case .expenseSource:
                return NSLocalizedString("Связывание кошельков", comment: "")
            case .expenseCategory:
                return NSLocalizedString("Связывание категорий расходов", comment: "")
            default:
                return nil
        }
    }
    
    var description: String? {
        switch linkingType {
            case .incomeSource:
                return NSLocalizedString("Для определения ваших источников доходов в транзакциях, свяжите их с источниками из нашего списка", comment: "")
            case .expenseSource:
                return NSLocalizedString("Чтобы вам было проще подключить ваши кошельки к банкам, свяжите их с банками из нашего списка", comment: "")
            case .expenseCategory:
                return NSLocalizedString("Для определения ваших категорий расходов в транзакциях, свяжите их с категориями из нашего списка", comment: "")
            default:
                return nil
        }
    }
    
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
    
    func link(_ linkingTransactionable: LinkingTransactionableViewModel, example: TransactionableExample?) -> Promise<Void> {
        return
            firstly {
                set(linkingTransactionable.transactionable, example: example)
            }.then {
                self.loadData()
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

extension PrototypesLinkingViewModel {
    private func set(_ transactionable: Transactionable, example: TransactionableExample?) -> Promise<Void> {
        switch transactionable {
            case let incomeSourceViewModel as IncomeSourceViewModel:
                return set(incomeSource: incomeSourceViewModel.incomeSource, example: example)
            case let expenseSourceViewModel as ExpenseSourceViewModel:
                return set(expenseSource: expenseSourceViewModel.expenseSource, example: example)
            case let expenseCategoryViewModel as ExpenseCategoryViewModel:
                return set(expenseCategory: expenseCategoryViewModel.expenseCategory, example: example)
            default:
                return Promise.value(())
        }
    }
    
    private func set(incomeSource: IncomeSource, example: TransactionableExample?) -> Promise<Void> {
        var updatingForm = incomeSource.toUpdatingForm()
        updatingForm.description = example?.localizedDescription
        updatingForm.prototypeKey = example?.prototypeKey
        return incomeSourcesCoordinator.update(with: updatingForm)
    }
    
    private func set(expenseSource: ExpenseSource, example: TransactionableExample?) -> Promise<Void> {
        var updatingForm = expenseSource.toUpdatingForm()
        updatingForm.prototypeKey = example?.prototypeKey
        return expenseSourcesCoordinator.update(with: updatingForm)
    }
    
    private func set(expenseCategory: ExpenseCategory, example: TransactionableExample?) -> Promise<Void> {
        var updatingForm = expenseCategory.toUpdatingForm()
        updatingForm.description = example?.localizedDescription
        updatingForm.prototypeKey = example?.prototypeKey
        return expenseCategoriesCoordinator.update(with: updatingForm)
    }
}

