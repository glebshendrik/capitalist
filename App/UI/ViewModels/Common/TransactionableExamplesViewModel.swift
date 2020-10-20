//
//  TransactionableExamplesViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 15.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionableExamplesViewModel {
    private let transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    
    private var examples: [TransactionableExampleViewModel] = []
    
    var transactionableType: TransactionableType = .expenseSource
    
    var isUsed: Bool = false
    
    private var basketType: BasketType? {
        return transactionableType == .expenseCategory ? .joy : nil
    }
    
    var title: String {
        switch transactionableType {
            case .expenseSource:
                return NSLocalizedString("Выберите шаблон кошелька", comment: "")
            case .incomeSource:
                return NSLocalizedString("Выберите шаблон источника дохода", comment: "")
            case .expenseCategory:
                return NSLocalizedString("Выберите шаблон категории расходов", comment: "")
            default:
                return ""
        }
    }
    
    var numberOfExamples: Int {
        return examples.count
    }
    
    init(transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol) {
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return
            firstly {
                transactionableExamplesCoordinator.indexBy(transactionableType, basketType: basketType, isUsed: isUsed)
            }.get { examples in
                self.examples = examples.map { TransactionableExampleViewModel(example: $0) }
            }.asVoid()
    }
    
    func exampleViewModel(by indexPath: IndexPath) -> TransactionableExampleViewModel? {
        return examples[safe: indexPath.row]
    }
}

protocol TransactionableExamplesDependantProtocol : class {
    var isNew: Bool { get }
    var numberOfUnusedExamples: Int { get set }
    var needToShowExamples: Bool { get }
    var basketType: BasketType { get }
    var transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol { get }
    var example: TransactionableExampleViewModel? { get set }
    var transactionableType: TransactionableType { get }
    
    func loadExamples() -> Promise<Void>
}

extension TransactionableExamplesDependantProtocol {
    var needToShowExamples: Bool {
        return isNew && numberOfUnusedExamples > 0 && example == nil
    }
    
    func loadExamples() -> Promise<Void> {
        let basket = transactionableType == .expenseCategory ? basketType : nil
        return
            firstly {
                transactionableExamplesCoordinator.indexBy(transactionableType, basketType: basket, isUsed: false)
            }.get { examples in
                self.numberOfUnusedExamples = examples.count
            }.asVoid()
    }
}
