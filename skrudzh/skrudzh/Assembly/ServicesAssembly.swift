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
                
        container.register(IconsServiceProtocol.self) { r in
            return IconsService(
                apiClient: r.resolve(APIClientProtocol.self)!)
        }
    }
}
