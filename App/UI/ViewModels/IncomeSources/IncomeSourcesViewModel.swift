//
//  IncomeSourcesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ItemsSection {
    case adding
    case items
}

class IncomeSourcesViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    private var incomeSourceViewModels: [IncomeSourceViewModel] = []
    
    var currenUser: User? = nil
    
    var currency: Currency? {
        return currenUser?.currency
    }
    
    var period: DatePeriod? {
        return DatePeriod.fromAccountingPeriod(currenUser?.defaultPeriod)
    }
    
    var periodTitle: String? {
        guard let period = period else { return nil }
        return DateRangeTransactionFilter(datePeriod: period).title
    }
    
    var total: String? = nil
    
    var totalSubtitle: String? {
        guard let periodTitle = periodTitle else { return nil }
        return String(format: NSLocalizedString("Доход за %@", comment: "Доход за %@"), periodTitle)
    }
    
    private var sections: [ItemsSection] {
        return isAddingAllowed ? [.adding, .items] : [.items]
    }
    
    var isAddingAllowed: Bool = true
    var noBorrows: Bool = true
    var isUpdatingData: Bool = false
    var shouldCalculateTotal: Bool = false
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var numberOfIncomeSources: Int {
        return incomeSourceViewModels.count
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.accountCoordinator = accountCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func loadData() -> Promise<Void> {
        guard shouldCalculateTotal else { return loadIncomeSources() }
        return  firstly {
                    loadCurrentUser()
                }.then {
                    self.loadIncomeSources()
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
    
    func loadIncomeSources() -> Promise<Void> {
        return  firstly {
                    incomeSourcesCoordinator.index(noBorrows: noBorrows)
                }.get { incomeSources in
                    self.incomeSourceViewModels = incomeSources.map { IncomeSourceViewModel(incomeSource: $0)}
                }.asVoid()
    }
    
    func calculateTotal() -> Promise<Void> {
        guard let currency = currency else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
        
        let amounts = incomeSourceViewModels.map { Amount(cents: $0.amountCents, currency: $0.currency) }
        
        return  firstly {
                    currencyConverter.summUp(amounts: amounts, currency: currency)                    
                }.get { total in
                    self.total = total.moneyCurrencyString(with: currency, shouldRound: false)
                }.asVoid()
    }
    
    func removeIncomeSource(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return incomeSourcesCoordinator.destroy(by: id, deleteTransactions: deleteTransactions)
    }
        
    func incomeSourceViewModel(at indexPath: IndexPath) -> IncomeSourceViewModel? {        
        return incomeSourceViewModels[safe: indexPath.row]
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
            return numberOfIncomeSources
        }
    }
    
    func moveIncomeSource(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Promise<Void> {
        let movingIncomeSource = incomeSourceViewModels.remove(at: sourceIndexPath.item)
        incomeSourceViewModels.insert(movingIncomeSource, at: destinationIndexPath.item)
        
        return  firstly {
                    incomeSourcesCoordinator.updatePosition(with: IncomeSourcePositionUpdatingForm(id: movingIncomeSource.id,
                                                                                                   position: destinationIndexPath.row))
                }.then {
                    self.loadIncomeSources()
                }
    }
}
