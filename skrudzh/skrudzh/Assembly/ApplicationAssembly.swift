//
//  ApplicationAssembly.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Swinject
import SwinjectStoryboard

struct Infrastructure {

    enum Storyboard : String {
        case Join, Main
        
        var name: String { return self.rawValue }
        
        static func all() -> [Storyboard] {
            return [.Main, .Join]
        }
    }

    enum ViewController : String {
        
        // Join
        case LandingViewController
        case RegistrationViewController
        
        // Main
        case MainViewController
        case MenuViewController
        case MenuNavigationController
        
        var identifier: String {
            return self.rawValue
        }
        
        var storyboard: Storyboard {
            switch self {
            case .LandingViewController,
                 .RegistrationViewController:
                return .Join
            case .MainViewController,
                 .MenuViewController,
                 .MenuNavigationController:
                return .Main
            }
        }
    }
}

class ApplicationAssembly: Assembly {
    
    func assemble(container: Container) {
        
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
    
    func registerViewControllers(in container: Container) {
        // MenuViewController
        container.registerForSkrudzhStoryboard(MenuViewController.self) { (r, c) in
            c.viewModel = r.resolve(MenuViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // RegistrationViewController
        container.registerForSkrudzhStoryboard(RegistrationViewController.self) { (r, c) in
            c.viewModel = r.resolve(RegistrationViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
    }
    
    func registerViewModels(in container: Container) {
        // SignInViewModel
        container.register(MenuViewModel.self) { r in
            return MenuViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // RegistrationViewModel
        container.register(RegistrationViewModel.self) { r in
            return RegistrationViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
    }
    
    static func resolveAppDelegateDependencies(appDelegate: AppDelegate) {
        let resolver = appDelegate.assembler.resolver
        appDelegate.window = resolver.resolve(UIWindow.self)
        appDelegate.router = resolver.resolve(ApplicationRouterProtocol.self)
        appDelegate.notificationsCoordinator = resolver.resolve(NotificationsCoordinatorProtocol.self)
    }
}

fileprivate extension Container {
    
    func registerForSkrudzhStoryboard<C:Controller>(_ controllerType: C.Type, name: String? = nil, initCompleted: ((Resolver, C) -> ())? = nil) {
        self.storyboardInitCompleted(controllerType, name: name) { (r, c) in
            initCompleted?(r, c)
        }
    }
    
}
