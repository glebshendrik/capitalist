//
//  ServicesAssembly.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        
        container.autoregister(APIClientProtocol.self, initializer: APIClient.init).inObjectScope(.container)        
        
        container.autoregister(AuthenticationServiceProtocol.self, initializer: AuthenticationService.init)
        
        container.autoregister(UsersServiceProtocol.self, initializer: UsersService.init)
        
        container.autoregister(DevicesServiceProtocol.self, initializer: DevicesService.init)

        container.autoregister(IncomeSourcesServiceProtocol.self, initializer: IncomeSourcesService.init)
        
        container.autoregister(ExpenseSourcesServiceProtocol.self, initializer: ExpenseSourcesService.init)
        
        container.autoregister(ExpenseCategoriesServiceProtocol.self, initializer: ExpenseCategoriesService.init)
        
        container.autoregister(IconsServiceProtocol.self, initializer: IconsService.init)
        
        container.autoregister(BasketsServiceProtocol.self, initializer: BasketsService.init)
        
        container.autoregister(CurrenciesServiceProtocol.self, initializer: CurrenciesService.init)
        
        container.autoregister(IncomesServiceProtocol.self, initializer: IncomesService.init)
        
        container.autoregister(ExchangeRatesServiceProtocol.self, initializer: ExchangeRatesService.init)
        
        container.autoregister(ExpensesServiceProtocol.self, initializer: ExpensesService.init)
        
        container.autoregister(FundsMovesServiceProtocol.self, initializer: FundsMovesService.init)
        
        container.autoregister(HistoryTransactionsServiceProtocol.self, initializer: HistoryTransactionsService.init)
        
        container.autoregister(AccountConnectionsServiceProtocol.self, initializer: AccountConnectionsService.init)
        
        container.autoregister(ProviderConnectionsServiceProtocol.self, initializer: ProviderConnectionsService.init)
        
        container.autoregister(BorrowsServiceProtocol.self, initializer: BorrowsService.init)
        
        container.autoregister(CreditsServiceProtocol.self, initializer: CreditsService.init)
        
        container.autoregister(CreditTypesServiceProtocol.self, initializer: CreditTypesService.init)
        
        container.autoregister(ActiveTypesServiceProtocol.self, initializer: ActiveTypesService.init)
    }
}
