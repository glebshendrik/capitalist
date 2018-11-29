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
        case Join, Main, Onboarding, Profile, Settings, Credits, FAQ, Blog
        
        var name: String { return self.rawValue }
        
        static func all() -> [Storyboard] {
            return [.Join, .Main, .Onboarding, .Profile, .Settings, .Credits, .FAQ, .Blog]
        }
    }

    enum ViewController : String {
        
        // Join
        case JoinViewController
    //    case LandingViewController
    //    case JoinNavigationController
    //    case JoinViewController
    //    case SignInViewController
    //    case SignUpViewController
        
        // Main
    //    case MainTabBarController
        
        var identifier: String {
            return self.rawValue
        }
        
        var storyboard: Storyboard {
            return .Join
    //        switch self {
    //        case .LandingViewController,
    //             .JoinNavigationController,
    //             .JoinViewController,
    //             .SignInViewController,
    //             .SignUpViewController:
    //            return .Join
    //        case .MainTabBarController:
    //            return .Main
    //        case .AccountViewController,
    //             .AccountSettingsViewController,
    //             .AccountEditViewController,
    //             .PlayerViewController,
    //             .PlayerEditViewController,
    //             .PlayerEditNavigationController,
    //             .UserPlayerDetailsViewController:
    //            return .Account
    //        case .PlayerVacancyViewController,
    //             .PlayerVacancyEditViewController,
    //             .PlayerVacancyEditNavigationController,
    //             .TeamVacancyViewController,
    //             .TeamVacancyEditViewController,
    //             .TeamVacancyEditNavigationController:
    //            return .Vacancies
    //        case .OffersViewController,
    //             .OfferedPlayerNavigationController,
    //             .OfferedTeamNavigationController,
    //             .OfferedPlayerViewController,
    //             .OfferedTeamViewController,
    //             .LikedOfferViewController:
    //            return .Offers
    //        case .TeamsViewController,
    //             .TeamViewController,
    //             .TeamDetailsViewController,
    //             .TeamMemberEditViewController,
    //             .TeamEditViewController,
    //             .TeamEditNavigationController,
    //             .TeamVacanciesViewController:
    //            return .Teams
    //        }
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
        
        
        // AccountViewController
//        container.registerForRedRoverStoryboard(AccountViewController.self) { (r, c) in
//            c.viewModel = r.resolve(AccountViewModel.self)
//            c.router = r.resolve(ApplicationRouterProtocol.self)
//        }
        
        
    }
    
    func registerViewModels(in container: Container) {
        // SignInViewModel
//        container.register(SignInViewModel.self) { r in
//            return SignInViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
//        }
        
        
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
