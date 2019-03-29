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
        case Join, Main, Profile, Onboarding, Settings, Statistics
        
        var name: String { return self.rawValue }
        
        static func all() -> [Storyboard] {
            return [.Main, .Join, .Profile, .Onboarding, .Settings, .Statistics]
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
        case IconsViewController
        case ExpenseCategoryEditNavigationController
        case ExpenseCategoryEditViewController
        case DependentIncomeSourceCreationMessageViewController
        case CurrenciesViewController
        case IncomeEditNavigationController
        case IncomeEditViewController
        case ExpenseEditNavigationController
        case ExpenseEditViewController
        case FundsMoveEditNavigationController
        case FundsMoveEditViewController
        case SlideUpContainerViewController
        case IncomeSourceSelectViewController
        case ExpenseSourceSelectViewController
        case ExpenseCategorySelectViewController
        
        // Profile
        case ProfileViewController
        case ChangePasswordViewController
        
        // Settings
        case SettingsViewController
        
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
        
        // Statistics
        case StatisticsViewController
        
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
                 .ExpenseSourceEditViewController,
                 .IconsViewController,
                 .ExpenseCategoryEditNavigationController,
                 .ExpenseCategoryEditViewController,
                 .DependentIncomeSourceCreationMessageViewController,
                 .CurrenciesViewController,
                 .IncomeEditNavigationController,
                 .IncomeEditViewController,
                 .ExpenseEditNavigationController,
                 .ExpenseEditViewController,
                 .FundsMoveEditNavigationController,
                 .FundsMoveEditViewController,
                 .SlideUpContainerViewController,
                 .IncomeSourceSelectViewController,
                 .ExpenseSourceSelectViewController,
                 .ExpenseCategorySelectViewController:
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
            case .SettingsViewController:
                return .Settings
            case .StatisticsViewController:
                return .Statistics
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
            c.soundsManager = r.resolve(SoundsManagerProtocol.self)
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
        
        // ExpenseSourceEditViewController
        container.registerForSkrudzhStoryboard(ExpenseSourceEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseSourceEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // IconsViewController
        container.registerForSkrudzhStoryboard(IconsViewController.self) { (r, c) in
            c.viewModel = r.resolve(IconsViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseCategoryEditViewController
        container.registerForSkrudzhStoryboard(ExpenseCategoryEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseCategoryEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // SettingsViewController
        container.registerForSkrudzhStoryboard(SettingsViewController.self) { (r, c) in
            c.viewModel = r.resolve(SettingsViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // CurrenciesViewController
        container.registerForSkrudzhStoryboard(CurrenciesViewController.self) { (r, c) in
            c.viewModel = r.resolve(CurrenciesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // IncomeEditViewController
        container.registerForSkrudzhStoryboard(IncomeEditViewController.self) { (r, c) in
            c.incomeEditViewModel = r.resolve(IncomeEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // ExpenseEditViewController
        container.registerForSkrudzhStoryboard(ExpenseEditViewController.self) { (r, c) in
            c.expenseEditViewModel = r.resolve(ExpenseEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // FundsMoveEditViewController
        container.registerForSkrudzhStoryboard(FundsMoveEditViewController.self) { (r, c) in
            c.fundsMoveEditViewModel = r.resolve(FundsMoveEditViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // SlideUpContainerViewController
        container.registerForSkrudzhStoryboard(SlideUpContainerViewController.self) { (r, c) in
//            c.fundsMoveEditViewModel = r.resolve(FundsMoveEditViewModel.self)
//            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
//            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // IncomeSourceSelectViewController
        container.registerForSkrudzhStoryboard(IncomeSourceSelectViewController.self) { (r, c) in
            c.viewModel = r.resolve(IncomeSourcesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseSourceSelectViewController
        container.registerForSkrudzhStoryboard(ExpenseSourceSelectViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseSourcesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseCategorySelectViewController
        container.registerForSkrudzhStoryboard(ExpenseCategorySelectViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseCategoriesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // StatisticsViewController
        container.registerForSkrudzhStoryboard(StatisticsViewController.self) { (r, c) in
            c.viewModel = r.resolve(StatisticsViewModel.self)
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
                                 expenseSourcesCoordinator: r.resolve(ExpenseSourcesCoordinatorProtocol.self)!,
                                 basketsCoordinator: r.resolve(BasketsCoordinatorProtocol.self)!,
                                 expenseCategoriesCoordinator: r.resolve(ExpenseCategoriesCoordinatorProtocol.self)!,
                                 accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // IncomeSourceEditViewModel
        container.register(IncomeSourceEditViewModel.self) { r in
            return IncomeSourceEditViewModel(incomeSourcesCoordinator: r.resolve(IncomeSourcesCoordinatorProtocol.self)!,
                                             accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // ExpenseSourceEditViewModel
        container.register(ExpenseSourceEditViewModel.self) { r in
            return ExpenseSourceEditViewModel(expenseSourcesCoordinator: r.resolve(ExpenseSourcesCoordinatorProtocol.self)!,
                                             accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // IconsViewModel
        container.register(IconsViewModel.self) { r in
            return IconsViewModel(iconsCoordinator: r.resolve(IconsCoordinatorProtocol.self)!)
        }
        
        // ExpenseCategoryEditViewModel
        container.register(ExpenseCategoryEditViewModel.self) { r in
            return ExpenseCategoryEditViewModel(expenseCategoriesCoordinator: r.resolve(ExpenseCategoriesCoordinatorProtocol.self)!,
                                              accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // SettingsViewModel
        container.register(SettingsViewModel.self) { r in            
            return SettingsViewModel(accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!,
                                     settingsCoordinator: r.resolve(SettingsCoordinatorProtocol.self)!,
                                     soundsManager: r.resolve(SoundsManagerProtocol.self)!)
        }
        
        // CurrenciesViewModel
        container.register(CurrenciesViewModel.self) { r in
            return CurrenciesViewModel(currenciesCoordinator: r.resolve(CurrenciesCoordinatorProtocol.self)!)
        }
        
        // IncomeEditViewModel
        container.register(IncomeEditViewModel.self) { r in
            return IncomeEditViewModel(incomesCoordinator: r.resolve(IncomesCoordinatorProtocol.self)!,
                                       accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!,
                                       exchangeRatesCoordinator: r.resolve(ExchangeRatesCoordinatorProtocol.self)!)
        }
        
        // ExpenseEditViewModel
        container.register(ExpenseEditViewModel.self) { r in
            return ExpenseEditViewModel(expensesCoordinator: r.resolve(ExpensesCoordinatorProtocol.self)!,
                                       accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!,
                                       exchangeRatesCoordinator: r.resolve(ExchangeRatesCoordinatorProtocol.self)!)
        }
        
        // FundMoveEditViewModel
        container.register(FundsMoveEditViewModel.self) { r in
            return FundsMoveEditViewModel(fundsMovesCoordinator: r.resolve(FundsMovesCoordinatorProtocol.self)!,
                                        accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!,
                                        exchangeRatesCoordinator: r.resolve(ExchangeRatesCoordinatorProtocol.self)!)
        }
        
        // IncomeSourcesViewModel
        container.register(IncomeSourcesViewModel.self) { r in
            return IncomeSourcesViewModel(incomeSourcesCoordinator: r.resolve(IncomeSourcesCoordinatorProtocol.self)!)
        }
        
        // ExpenseSourcesViewModel
        container.register(ExpenseSourcesViewModel.self) { r in
            return ExpenseSourcesViewModel(expenseSourcesCoordinator: r.resolve(ExpenseSourcesCoordinatorProtocol.self)!)
        }
        
        // ExpenseCategoriesViewModel
        container.register(ExpenseCategoriesViewModel.self) { r in
            return ExpenseCategoriesViewModel(expenseCategoriesCoordinator: r.resolve(ExpenseCategoriesCoordinatorProtocol.self)!)
        }
        
        // StatisticsViewModel
        container.register(StatisticsViewModel.self) { r in
            return StatisticsViewModel(historyTransactionsViewModel: r.resolve(HistoryTransactionsViewModel.self)!,
                                       filtersViewModel: r.resolve(FiltersViewModel.self)!)
        }
        
        // HistoryTransactionsViewModel
        container.register(HistoryTransactionsViewModel.self) { r in
            return HistoryTransactionsViewModel(historyTransactionsCoordinator: r.resolve(HistoryTransactionsCoordinatorProtocol.self)!,
                                                exchangeRatesCoordinator: r.resolve(ExchangeRatesCoordinatorProtocol.self)!,
                                                accountCoordinator: r.resolve(AccountCoordinatorProtocol.self)!)
        }
        
        // FiltersViewModel
        container.register(FiltersViewModel.self) { r in
            return FiltersViewModel()
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
