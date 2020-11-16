//
//  TransactionablesCreationViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class TransactionablesCreationViewModel {
    private let transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    private var examples: [TransactionableExampleViewModel] = [] {
        didSet {
            examplesHash = examples.reduce(into: [String: TransactionableExampleViewModel]()) { $0[$1.prototypeKey] = $1 }
        }
    }
    private var examplesHash: [String: TransactionableExampleViewModel] = [:]
    
    private var transactionables: [Transactionable] = [] {
        didSet {
            transactionablesHash = transactionables.reduce(into: [String: Transactionable]()) {
                if let prototypeKey = $1.prototypeKey {
                    $0[prototypeKey] = $1
                }
            }
        }
    }
    private var transactionablesHash: [String: Transactionable] = [:]
                
    var title: String {
        return NSLocalizedString("Добавьте ваши кошельки", comment: "")
    }
    
    var subtitle: String {
        return NSLocalizedString("Добавьте наличные, ваши банковские счета, электронные кошельки и другие кошельки, которыми вы пользуетесь. Оформив платную подписку, можно привязывать кошельки к вашим реальным банковским счетам, чтобы вам не приходилось заносить ваши операции вручную. Необходимо добавить хотя бы один кошелек.", comment: "")
    }
    
    var canGoNext: Bool {
        return numberOfTransactionables > 0
    }
    
    var nextButtonEnabled: Bool {
        return canGoNext
    }
        
    var numberOfExamples: Int {
        return examples.count
    }
    
    var numberOfTransactionables: Int {
        return transactionables.count
    }
    
    init(transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
       
    func exampleViewModel(by indexPath: IndexPath) -> TransactionableExampleViewModel? {
        return examples[safe: indexPath.row]
    }
    
    func transactionable(by prototypeKey: String) -> Transactionable? {
        return transactionablesHash[prototypeKey]
    }
    
    func loadData() -> Promise<Void> {
        return
            firstly {
                when(fulfilled: loadExpenseSources(), loadExamples())
            }.get { transactionables, examples in
                self.transactionables = transactionables
                self.examples = examples
                self.updateSelectedExamples()
            }.asVoid()
    }
    
    private func loadExpenseSources() -> Promise<[Transactionable]> {
        return
            firstly {
                expenseSourcesCoordinator.index(currency: nil)
            }.map { expenseSources in
                expenseSources.map { ExpenseSourceViewModel(expenseSource: $0)}
            }
    }
    
    private func loadExamples() -> Promise<[TransactionableExampleViewModel]> {
        return
            firstly {
                transactionableExamplesCoordinator.indexBy(.expenseSource,
                                                           basketType: nil,
                                                           isUsed: nil)
            }.map { examples in
                examples.map { TransactionableExampleViewModel(example: $0) }
            }
    }
    
    private func updateSelectedExamples() {
        for example in examples {
            example.selected = false
        }
        var examplesToAdd = [TransactionableExampleViewModel]()
        for transactionable in transactionables {
            guard
                let prototypeKey = transactionable.prototypeKey
            else {
                continue
            }
            if let _ = examplesHash[prototypeKey] {
                examplesHash[prototypeKey]?.selected = true
            }
            else {
                let example = TransactionableExampleViewModel(transactionable: transactionable)
                examplesToAdd.append(example)
                examplesHash[prototypeKey] = example
            }            
        }
        examples.insert(contentsOf: examplesToAdd, at: 0)
    }
}
