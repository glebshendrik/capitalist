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
    }
}
