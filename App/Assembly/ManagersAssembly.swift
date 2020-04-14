//
//  ManagersAssembly.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

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
                notificationsCoordinator: r.resolve(NotificationsCoordinatorProtocol.self)!,
                soundsManager: r.resolve(SoundsManagerProtocol.self)!,
                analyticsManager: r.resolve(AnalyticsManagerProtocol.self)!,
                biometricVerificationManager: r.resolve(BiometricVerificationManagerProtocol.self)!,
                userPreferencesManager: r.resolve(UserPreferencesManagerProtocol.self)!)
            }
            .inObjectScope(.container)
            .initCompleted { resolver, router in
                router.initDependencies(with: resolver)
        }
        
        container.autoregister(UserSessionManagerProtocol.self, initializer: UserSessionManager.init).inObjectScope(.container)
        
        container.autoregister(UIMessagePresenterManagerProtocol.self, initializer: UIMessagePresenterManager.init).inObjectScope(.container)
        
        container.autoregister(NotificationsManagerProtocol.self, initializer: NotificationsManager.init).inObjectScope(.container)
        
        container.autoregister(NotificationsHandlerProtocol.self, initializer: NotificationsHandler.init).inObjectScope(.container)
        
        container.autoregister(NavigatorProtocol.self, initializer: Navigator.init).inObjectScope(.container)
        
        container.autoregister(SoundsManagerProtocol.self, initializer: SoundsManager.init).inObjectScope(.container)
        
        container.autoregister(CurrencyConverterProtocol.self, initializer: CurrencyConverter.init).inObjectScope(.container)
        
        container.autoregister(ExportManagerProtocol.self, initializer: ExportManager.init).inObjectScope(.container)
        
        container.autoregister(SaltEdgeManagerProtocol.self, initializer: SaltEdgeManager.init).inObjectScope(.container)
        
        container.autoregister(UIFactoryProtocol.self, initializer: UIFactory.init).inObjectScope(.container)
        
        container.autoregister(AnalyticsManagerProtocol.self, initializer: AnalyticsManager.init).inObjectScope(.container)
        
        container.autoregister(BiometricVerificationManagerProtocol.self, initializer: BiometricVerificationManager.init).inObjectScope(.container)
        
        container.autoregister(UserPreferencesManagerProtocol.self, initializer: UserPreferencesManager.init).inObjectScope(.container)
    }
    
}
