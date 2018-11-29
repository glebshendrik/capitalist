//
//  ManagersAssembly.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Swinject

class ManagersAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // ApplicationRouterProtocol
        container.register(ApplicationRouterProtocol.self) { r in
            
            // Resolve storyboards:
            var storyboards: [Infrastructure.Storyboard: UIStoryboard] = [:]
            for storyboard in Infrastructure.Storyboard.all() {
                storyboards[storyboard] = r.resolve(UIStoryboard.self, name: storyboard.name)
            }
            
            return ApplicationRouter(
                with: storyboards,
                window: r.resolve(UIWindow.self)!,
                userSessionManager: r.resolve(UserSessionManagerProtocol.self)!,
                notificationsCoordinator: r.resolve(NotificationsCoordinatorProtocol.self)!)
            }
            .inObjectScope(.container)
            .initCompleted { resolver, router in
                router.initDependencies(with: resolver)
        }
        
        // UserSessionManagerProtocol
        container.register(UserSessionManagerProtocol.self) { r in
            return UserSessionManager()
            }.inObjectScope(.container)
        
        // UIMessagePresenterManagerProtocol
        container.register(UIMessagePresenterManagerProtocol.self) { r in
            return UIMessagePresenterManager()
            }.inObjectScope(.container)
        
        // NotificationsManagerProtocol
        container.register(NotificationsManagerProtocol.self) { r in
            return NotificationsManager(notificationsHandler: r.resolve(NotificationsHandlerProtocol.self)!)
            }.inObjectScope(.container)
        
        // NotificationsHandlerProtocol
        container.register(NotificationsHandlerProtocol.self) { r in
            return NotificationsHandler(navigator: r.resolve(NavigatorProtocol.self)!,
                                        messagePresenterManager: r.resolve(UIMessagePresenterManagerProtocol.self)!)
            }.inObjectScope(.container)
        
        // Navigator
        container.register(NavigatorProtocol.self) { r in
            return Navigator(window: r.resolve(UIWindow.self)!)
            }.inObjectScope(.container)
        
    }
    
}
