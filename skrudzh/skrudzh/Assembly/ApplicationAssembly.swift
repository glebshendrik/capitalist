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
        case Join, Main, Profile, Onboarding
        
        var name: String { return self.rawValue }
        
        static func all() -> [Storyboard] {
            return [.Main, .Join, .Profile, .Onboarding]
        }
    }

    enum ViewController : String {
        
        // Join
        case LandingViewController
        case RegistrationViewController
        case LoginViewController
        case ForgotPasswordViewController
        case ResetPasswordViewController
        
        // Main
        case MainViewController
        case MenuViewController
        case MenuNavigationController
        case IncomeSourceEditViewController
        case IncomeSourceEditNavigationController
        case ExpenseSourceEditNavigationController
        case ExpenseSourceEditViewController
        
        // Profile
        case ProfileViewController
        case ChangePasswordViewController
        
        // Onboarding
        case OnboardingViewController
        case OnboardingPage1ViewController
        case OnboardingPage2ViewController
        case OnboardingPage3ViewController
        case OnboardingPage4ViewController
        case OnboardingPage5ViewController
        case OnboardingPage6ViewController
        case OnboardingPage7ViewController
        case OnboardingPage8ViewController
        
        var identifier: String {
            return self.rawValue
        }
        
        var storyboard: Storyboard {
            switch self {
            case .LandingViewController,
                 .RegistrationViewController,
                 .LoginViewController,
                 .ForgotPasswordViewController,
                 .ResetPasswordViewController:
                return .Join
            case .MainViewController,
                 .MenuViewController,
                 .MenuNavigationController,
                 .IncomeSourceEditViewController,
                 .IncomeSourceEditNavigationController,
                 .ExpenseSourceEditNavigationController,
                 .ExpenseSourceEditViewController:
                return .Main
            case .ProfileViewController,
                 .ChangePasswordViewController:
                return .Profile
            case .OnboardingViewController,
                 .OnboardingPage1ViewController,
                 .OnboardingPage2ViewController,
                 .OnboardingPage3ViewController,
                 .OnboardingPage4ViewController,
                 .OnboardingPage5ViewController,
                 .OnboardingPage6ViewController,
                 .OnboardingPage7ViewController,
                 .OnboardingPage8ViewController:
                return .Onboarding
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
        
        // LandingViewController
        container.registerForSkrudzhStoryboard(LandingViewController.self) { (r, c) in
        }
        
        // MainViewController
        container.registerForSkrudzhStoryboard(MainViewController.self) { (r, c) in
            c.viewModel = r.resolve(MainViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // RegistrationViewController
        container.registerForSkrudzhStoryboard(RegistrationViewController.self) { (r, c) in
            c.viewModel = r.resolve(RegistrationViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ProfileViewController
        container.registerForSkrudzhStoryboard(ProfileViewController.self) { (r, c) in
            c.viewModel = r.resolve(ProfileViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // LoginViewController
        container.registerForSkrudzhStoryboard(LoginViewController.self) { (r, c) in
            c.viewModel = r.resolve(LoginViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ForgotPasswordViewController
        container.registerForSkrudzhStoryboard(ForgotPasswordViewController.self) { (r, c) in
            c.viewModel = r.resolve(ForgotPasswordViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ResetPasswordViewController
        container.registerForSkrudzhStoryboard(ResetPasswordViewController.self) { (r, c) in
            c.viewModel = r.resolve(ResetPasswordViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ChangePasswordViewController
        container.registerForSkrudzhStoryboard(ChangePasswordViewController.self) { (r, c) in
            c.viewModel = r.resolve(ChangePasswordViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ProfileEditViewController
        container.registerForSkrudzhStoryboard(ProfileEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ProfileEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // OnboardingViewController
        container.registerForSkrudzhStoryboard(OnboardingViewController.self) { (r, c) in
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // IncomeSourceEditViewController
        container.registerForSkrudzhStoryboard(IncomeSourceEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(IncomeSourceEditViewModel.self)
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
        
        // ProfileViewModel
        container.register(ProfileViewModel.self) { r in
            return ProfileViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // LoginViewModel
        container.register(LoginViewModel.self) { r in
            return LoginViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // ForgotPasswordViewModel
        container.register(ForgotPasswordViewModel.self) { r in
            return ForgotPasswordViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // ResetPasswordViewModel
        container.register(ResetPasswordViewModel.self) { r in
            return ResetPasswordViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // ChangePasswordViewModel
        container.register(ChangePasswordViewModel.self) { r in
            return ChangePasswordViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // ProfileEditViewModel
        container.register(ProfileEditViewModel.self) { r in
            return ProfileEditViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // MainViewModel
        container.register(MainViewModel.self) { r in
            return MainViewModel(incomeSourcesCoordinator: r.resolve(IncomeSourcesCoordinatorProtocol.self)!,
                                 expenseSourcesCoordinator: r.resolve(ExpenseSourcesCoordinatorProtocol.self)!)
        }
        
        // IncomeSourceEditViewModel
        container.register(IncomeSourceEditViewModel.self) { r in
            return IncomeSourceEditViewModel(incomeSourcesCoordinator: r.resolve(IncomeSourcesCoordinatorProtocol.self)!,
                                             accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
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
