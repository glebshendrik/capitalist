//
//  ApplicationAssembly.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectStoryboard
import SwinjectAutoregistration

class ApplicationAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // Adjust logging function
        setContainerLoggingFunction()
        
        // UIStoryboard
        registerStoryboards(in: container)
        
        // UIWindow
        container.register(UIWindow.self) { r in
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.makeKeyAndVisible()
            return window
            }.inObjectScope(.container)
        
        registerViewModels(in: container)
        registerViewControllers(in: container)
    }
    
    func registerStoryboards(in container: Container) {
        for storyboard in Infrastructure.Storyboard.all() {
            container.register(UIStoryboard.self, name: storyboard.name) { r in
                return SwinjectStoryboard.create(name: storyboard.name, bundle: nil, container: r)
                }.inObjectScope(.container)
        }
    }
    
    static func resolveAppDelegateDependencies(appDelegate: AppDelegate) {
        let resolver = appDelegate.assembler.resolver
        appDelegate.window = resolver.resolve(UIWindow.self)
        appDelegate.router = resolver.resolve(ApplicationRouterProtocol.self)
        appDelegate.notificationsCoordinator = resolver.resolve(NotificationsCoordinatorProtocol.self)
    }
    
    private func setContainerLoggingFunction() {
        Container.loggingFunction = {

            // Find the text that contains the missing registration.
            if let startOfMissingRegistration = $0.range(of: "Swinject: Resolution failed. Expected registration:\n\t")?.upperBound,
                let startOfAvailableOptions = $0.range(of: "\nAvailable registrations:")?.lowerBound {
                let missingRegistration = $0[startOfMissingRegistration ..< startOfAvailableOptions]

                // Ignore all reports for UIKit classes.
                if missingRegistration.contains("Storyboard: UI")
                    || missingRegistration.contains("Storyboard: MyApp.IgnoreThisViewController")
                    /* || other classes you want to ignore here */  {
                    return
                }

                // Print the missing registration.
                print("Swinject failed to find registration for \(missingRegistration)")
                return
            }

            // Some other message so just print it.
            print($0)
        }
    }
}

extension Container {
    
    func registerForSkrudzhStoryboard<C:Controller>(_ controllerType: C.Type, name: String? = nil, initCompleted: ((Resolver, C) -> ())? = nil) {
                
        self.storyboardInitCompleted(controllerType, name: name) { (r, c) in
            
            if var messageManagerDependant = c as? UIMessagePresenterManagerDependantProtocol {
                messageManagerDependant.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
            }
            
            if var routerDependant = c as? ApplicationRouterDependantProtocol {
                routerDependant.router = r.resolve(ApplicationRouterProtocol.self)
            }
            
            if var factoryDependant = c as? UIFactoryDependantProtocol {
                factoryDependant.factory = r.resolve(UIFactoryProtocol.self)
            }
            
            if var analyticsManagerDependant = c as? AnalyticsManagerDependantProtocol {
                analyticsManagerDependant.analyticsManager = r.resolve(AnalyticsManagerProtocol.self)
            }
            
            initCompleted?(r, c)
        }
        
    }
    
}
