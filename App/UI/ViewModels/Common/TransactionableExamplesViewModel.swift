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
