//
//  ViewControllersRegistration.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectStoryboard

extension ApplicationAssembly {
    
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
            c.router = r.resolve(ApplicationRouterProtocol.self)
        }
        
        // FiltersSelectionViewController
        container.registerForSkrudzhStoryboard(FiltersSelectionViewController.self) { (r, c) in
            c.viewModel = r.resolve(FiltersSelectionViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // WaitingDebtsViewController
        container.registerForSkrudzhStoryboard(WaitingDebtsViewController.self) { (r, c) in
            c.viewModel = r.resolve(WaitingDebtsViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // BalanceViewController
        container.registerForSkrudzhStoryboard(BalanceViewController.self) { (r, c) in
            c.viewModel = r.resolve(BalanceViewModel.self)
        }
        
        // BalanceViewController
        container.registerForSkrudzhStoryboard(ReminderEditViewController.self) { (r, c) in            
        }
    }
}
