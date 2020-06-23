//
//  ExpenseSourcesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ExpenseSourcesViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    private var expenseSourceViewModels: [ExpenseSourceViewModel] = []
    
    var currenUser: User? = nil
    
    var currency: Currency? {
        return currenUser?.currency
    }
    
    var total: String? = nil
        
    private var sections: [ItemsSection] {
        return isAddingAllowed ? [.adding, .items] : [.items]
    }
    
    var isAddingAllowed: Bool = true
    var isUpdatingData: Bool = false
    var shouldCalculateTotal: Bool = false
    var skipExpenseSourceId: Int? = nil
    var currencyFilter: String? = nil
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var numberOfItems: Int {
        return expenseSourceViewModels.count
    }
    
    init(expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.accountCoordinator = accountCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func loadData() -> Promise<Void> {
        guard shouldCalculateTotal else { return loadExpenseSources() }
        return  firstly {
                    loadCurrentUser()
                }.then {
                    self.loadExpenseSources()
                }.then {
                    self.calculateTotal()
                }
    }
    
    func loadCurrentUser() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.get { user in
                    self.currenUser = user
                }.asVoid()
    }
    
    func loadExpenseSources() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.index(currency: currencyFilter)
                }.get { expenseSources in
                    self.expenseSourceViewModels = expenseSources
                        .map { ExpenseSourceViewModel(expenseSource: $0)}
                        .filter { $0.id != self.skipExpenseSourceId }
                }.asVoid()
    }
    
    func calculateTotal() -> Promise<Void> {
        guard let currency = currency else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
                
        let amounts = expenseSourceViewModels.map { Amount(cents: $0.amountCents, currency: $0.currency) }
        
        return  firstly {
                    currencyConverter.summUp(amounts: amounts, currency: currency)
                }.get { total in
                    self.total = total.moneyCurrencyString(with: currency, shouldRound: false)
                }.asVoid()
    }
    
    func removeExpenseSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return expenseSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
        
    func expenseSourceViewModel(at indexPath: IndexPath) -> ExpenseSourceViewModel? {
        return expenseSourceViewModels[safe: indexPath.row]
    }
    
    func section(at index: Int) -> ItemsSection? {
        return sections[safe: index]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = self.section(at: section) else { return 0 }
        switch section {
        case .adding:
            return 1
        case .items:
            return numberOfItems
        }
    }
}
