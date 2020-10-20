//
//  ActivesViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ActivesViewModel {
    private let activesCoordinator: ActivesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    private var activeViewModels: [ActiveViewModel] = []
    
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
    var skipActiveId: Int? = nil
    
    var numberOfSections: Int {
        return sections.count
    }
    
    var numberOfItems: Int {
        return activeViewModels.count
    }
    
    init(activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func loadData() -> Promise<Void> {
        guard shouldCalculateTotal else { return loadActives() }
        return  firstly {
                    loadCurrentUser()
                }.then {
                    self.loadActives()
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
    
    func loadActives() -> Promise<Void> {
        return  firstly {
                    activesCoordinator.indexUserActives()
                }.get { actives in
                    self.activeViewModels = actives
                        .map { ActiveViewModel(active: $0)}
                        .filter { $0.id != self.skipActiveId }
                }.asVoid()
    }
    
    func calculateTotal() -> Promise<Void> {
        guard let currency = currency else {
            return Promise(error: SessionError.noSessionInAuthorizedContext)
        }
                
        let amounts = activeViewModels.map { Amount(cents: $0.costCents, currency: $0.currency) }
        
        return  firstly {
                    currencyConverter.summUp(amounts: amounts, currency: currency)
                }.get { total in
                    self.total = total.moneyCurrencyString(with: currency, shouldRound: false)
                }.asVoid()
    }
    
    func removeActive(by id: Int, deleteTransactions: Bool) -> Promise<Void> {
        return activesCoordinator.destroyActive(by: id, deleteTransactions: deleteTransactions)
    }
        
    func activeViewModel(at indexPath: IndexPath) -> ActiveViewModel? {
        return activeViewModels[safe: indexPath.row]
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
