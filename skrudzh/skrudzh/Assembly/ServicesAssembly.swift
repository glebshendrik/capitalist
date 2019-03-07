//
//  ServicesAssembly.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Swinject

class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(APIClientProtocol.self) { r in
            return APIClient(userSessionManager: r.resolve(UserSessionManagerProtocol.self)!)
            }
            .inObjectScope(.container)
        
        container.register(AuthenticationServiceProtocol.self) { r in
            return AuthenticationService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(UsersServiceProtocol.self) { r in
            return UsersService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(DevicesServiceProtocol.self) { r in
            return DevicesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(IncomeSourcesServiceProtocol.self) { r in
            return IncomeSourcesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(ExpenseSourcesServiceProtocol.self) { r in
            return ExpenseSourcesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(ExpenseCategoriesServiceProtocol.self) { r in
            return ExpenseCategoriesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
                
        container.register(IconsServiceProtocol.self) { r in
            return IconsService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(BasketsServiceProtocol.self) { r in
            return BasketsService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(CurrenciesServiceProtocol.self) { r in
            return CurrenciesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(IncomesServiceProtocol.self) { r in
            return IncomesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(ExchangeRatesServiceProtocol.self) { r in
            return ExchangeRatesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(ExpensesServiceProtocol.self) { r in
            return ExpensesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
        
        container.register(FundsMovesServiceProtocol.self) { r in
            return FundsMovesService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
    }
}
