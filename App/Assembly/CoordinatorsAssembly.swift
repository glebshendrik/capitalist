//
//  CoordinatorsAssembly.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

class CoordinatorsAssembly: Assembly {
    func assemble(container: Container) {
        
        container.autoregister(AccountCoordinatorProtocol.self, initializer: AccountCoordinator.init)
        
        container.autoregister(NotificationsCoordinatorProtocol.self, initializer: NotificationsCoordinator.init)
        
        container.autoregister(IncomeSourcesCoordinatorProtocol.self, initializer: IncomeSourcesCoordinator.init)
        
        container.autoregister(ExpenseSourcesCoordinatorProtocol.self, initializer: ExpenseSourcesCoordinator.init)
        
        container.autoregister(ExpenseCategoriesCoordinatorProtocol.self, initializer: ExpenseCategoriesCoordinator.init)
        
        container.autoregister(IconsCoordinatorProtocol.self, initializer: IconsCoordinator.init)
        
        container.autoregister(BasketsCoordinatorProtocol.self, initializer: BasketsCoordinator.init)
        
        container.autoregister(SettingsCoordinatorProtocol.self, initializer: SettingsCoordinator.init)
        
        container.autoregister(CurrenciesCoordinatorProtocol.self, initializer: CurrenciesCoordinator.init)
                
        container.autoregister(ExchangeRatesCoordinatorProtocol.self, initializer: ExchangeRatesCoordinator.init)
                
        container.autoregister(TransactionsCoordinatorProtocol.self, initializer: TransactionsCoordinator.init)
        
        container.autoregister(BankConnectionsCoordinatorProtocol.self, initializer: BankConnectionsCoordinator.init)
        
        container.autoregister(BorrowsCoordinatorProtocol.self, initializer: BorrowsCoordinator.init)
        
        container.autoregister(CreditsCoordinatorProtocol.self, initializer: CreditsCoordinator.init)
        
        container.autoregister(ActivesCoordinatorProtocol.self, initializer: ActivesCoordinator.init)
    }
}
