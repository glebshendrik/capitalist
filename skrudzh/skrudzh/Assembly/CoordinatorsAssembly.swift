//
//  CoordinatorsAssembly.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Swinject

class CoordinatorsAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(AccountCoordinatorProtocol.self) { r in
            return AccountCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                                      authenticationService: r.resolve(AuthenticationServiceProtocol.self)!,
                                      usersService: r.resolve(UsersServiceProtocol.self)!,
                                      router: r.resolve(ApplicationRouterProtocol.self)!,
                                      notificationsCoordinator: r.resolve(NotificationsCoordinatorProtocol.self)!)
        }
        
        container.register(NotificationsCoordinatorProtocol.self) { r in
            return NotificationsCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                                            devicesService: r.resolve(DevicesServiceProtocol.self)!,
                                            notificationsManager: r.resolve(NotificationsManagerProtocol.self)!,
                                            navigator: r.resolve(NavigatorProtocol.self)!)
        }
        
        container.register(IncomeSourcesCoordinatorProtocol.self) { r in
            return IncomeSourcesCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                                            incomeSourcesService: r.resolve(IncomeSourcesServiceProtocol.self)!)
        }
        
        container.register(ExpenseSourcesCoordinatorProtocol.self) { r in
            return ExpenseSourcesCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                                            expenseSourcesService: r.resolve(ExpenseSourcesServiceProtocol.self)!)
        }
        
        container.register(ExpenseCategoriesCoordinatorProtocol.self) { r in
            return ExpenseCategoriesCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                                                expenseCategoriesService: r.resolve(ExpenseCategoriesServiceProtocol.self)!)
        }
        
        container.register(IconsCoordinatorProtocol.self) { r in
            return IconsCoordinator(iconsService: r.resolve(IconsServiceProtocol.self)!)
        }
        
        container.register(BasketsCoordinatorProtocol.self) { r in
            return BasketsCoordinator(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,                                      
                                      basketsService: r.resolve(BasketsServiceProtocol.self)!)
        }
        
        container.register(SettingsCoordinatorProtocol.self) { r in
            return SettingsCoordinator(usersService: r.resolve(UsersServiceProtocol.self)!)
        }
        
        container.register(CurrenciesCoordinatorProtocol.self) { r in
            return CurrenciesCoordinator(currenciesService: r.resolve(CurrenciesServiceProtocol.self)!)
        }
        
        container.register(IncomesCoordinatorProtocol.self) { r in
            return IncomesCoordinator(incomesService: r.resolve(IncomesServiceProtocol.self)!)
        }
        
        container.register(ExchangeRatesCoordinatorProtocol.self) { r in
            return ExchangeRatesCoordinator(exchangeRatesService: r.resolve(ExchangeRatesServiceProtocol.self)!)
        }
    }
}
