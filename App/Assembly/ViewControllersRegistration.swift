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
        }
        
        // OnboardingPagesViewController
        container.registerForSkrudzhStoryboard(OnboardingPagesViewController.self) { (r, c) in
        }
        
        // IncomeSourceEditViewController
        container.registerForSkrudzhStoryboard(IncomeSourceEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(IncomeSourceEditViewModel.self)
        }
        
        // ExpenseSourceEditViewController
        container.registerForSkrudzhStoryboard(ExpenseSourceEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseSourceEditViewModel.self)
        }
        
        // IconsViewController
        container.registerForSkrudzhStoryboard(IconsViewController.self) { (r, c) in
            c.viewModel = r.resolve(IconsViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseCategoryEditViewController
        container.registerForSkrudzhStoryboard(ExpenseCategoryEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseCategoryEditViewModel.self)
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
        
        // TransactionEditViewController
        container.registerForSkrudzhStoryboard(TransactionEditViewController.self) { (r, c) in            
            c.viewModel = r.resolve(TransactionEditViewModel.self)
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
        
        // IncomeSourcesViewController
        container.registerForSkrudzhStoryboard(IncomeSourcesViewController.self) { (r, c) in
            c.viewModel = r.resolve(IncomeSourcesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseSourceSelectViewController
        container.registerForSkrudzhStoryboard(ExpenseSourceSelectViewController.self) { (r, c) in
//            c.viewModel = r.resolve(ExpenseSourcesViewModel.self)
//            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // ExpenseSourcesViewController
        container.registerForSkrudzhStoryboard(ExpenseSourcesViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseSourcesViewModel.self)
//            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // CardTypesViewController
        container.registerForSkrudzhStoryboard(CardTypesViewController.self) { (r, c) in
            c.viewModel = r.resolve(CardTypesViewModel.self)
        }
        
        // ExpenseCategorySelectViewController
        container.registerForSkrudzhStoryboard(ExpenseCategorySelectViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseCategoriesViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // StatisticsViewController
        container.registerForSkrudzhStoryboard(StatisticsViewController.self) { (r, c) in
            c.viewModel = r.resolve(StatisticsViewModel.self)
        }
        
        // FiltersSelectionViewController
        container.registerForSkrudzhStoryboard(FiltersSelectionViewController.self) { (r, c) in
            c.viewModel = r.resolve(FiltersSelectionViewModel.self)
        }
        
        // DatePeriodSelectionViewController
        container.registerForSkrudzhStoryboard(DatePeriodSelectionViewController.self) { (r, c) in
            c.viewModel = r.resolve(DatePeriodSelectionViewModel.self)
        }
        
        // WaitingBorrowsViewController
        container.registerForSkrudzhStoryboard(WaitingBorrowsViewController.self) { (r, c) in
            c.viewModel = r.resolve(WaitingBorrowsViewModel.self)
            c.messagePresenterManager = r.resolve(UIMessagePresenterManagerProtocol.self)
        }
        
        // BalanceViewController
        container.registerForSkrudzhStoryboard(BalanceViewController.self) { (r, c) in
            c.viewModel = r.resolve(BalanceViewModel.self)
        }
        
        // BalanceViewController
        container.registerForSkrudzhStoryboard(ReminderEditViewController.self) { (r, c) in            
        }
        
        // ProvidersViewController
        container.registerForSkrudzhStoryboard(ProvidersViewController.self) { (r, c) in
            c.viewModel = r.resolve(ProvidersViewModel.self)
        }
        
        // ProviderConnectionViewController
        container.registerForSkrudzhStoryboard(ProviderConnectionViewController.self) { (r, c) in
            c.viewModel = r.resolve(ProviderConnectionViewModel.self)
        }
        
        // AccountsViewController
        container.registerForSkrudzhStoryboard(AccountsViewController.self) { (r, c) in
            c.viewModel = r.resolve(AccountsViewModel.self)
        }
        
        // BorrowsViewController
        container.registerForSkrudzhStoryboard(BorrowsViewController.self) { (r, c) in
            c.viewModel = r.resolve(BorrowsViewModel.self)
        }
        
        // BorrowEditViewController
        container.registerForSkrudzhStoryboard(BorrowEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(BorrowEditViewModel.self)
        }
        
        // CreditsViewController
        container.registerForSkrudzhStoryboard(CreditsViewController.self) { (r, c) in
            c.viewModel = r.resolve(CreditsViewModel.self)
        }
        
        // CreditEditViewController
        container.registerForSkrudzhStoryboard(CreditEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(CreditEditViewModel.self)
        }
        
        // ActiveEditViewController
        container.registerForSkrudzhStoryboard(ActiveEditViewController.self) { (r, c) in
            c.viewModel = r.resolve(ActiveEditViewModel.self)
        }
        
        // ActiveSelectViewController
        container.registerForSkrudzhStoryboard(ActiveSelectViewController.self) { (r, c) in
//            c.viewModel = r.resolve(ActivesViewModel.self)
        }
        
        // ActivesViewController
        container.registerForSkrudzhStoryboard(ActivesViewController.self) { (r, c) in
            c.viewModel = r.resolve(ActivesViewModel.self)
        }
        
        
        // EntityInfoViewController
        container.registerForSkrudzhStoryboard(EntityInfoViewController.self) { (r, c) in
        }
        
        // IncomeSourceInfoViewController
        container.registerForSkrudzhStoryboard(IncomeSourceInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(IncomeSourceInfoViewModel.self)
        }
        
        // ExpenseSourceInfoViewController
        container.registerForSkrudzhStoryboard(ExpenseSourceInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseSourceInfoViewModel.self)
        }
        
        // ExpenseCategoryInfoViewController
        container.registerForSkrudzhStoryboard(ExpenseCategoryInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(ExpenseCategoryInfoViewModel.self)
        }
        
        // ActiveInfoViewController
        container.registerForSkrudzhStoryboard(ActiveInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(ActiveInfoViewModel.self)
        }
        
        // CreditInfoViewController
        container.registerForSkrudzhStoryboard(CreditInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(CreditInfoViewModel.self)
        }
        
        // BorrowInfoViewController
        container.registerForSkrudzhStoryboard(BorrowInfoViewController.self) { (r, c) in
            c.viewModel = r.resolve(BorrowInfoViewModel.self)
        }
        
        // TransactionablesCreationViewController
        container.registerForSkrudzhStoryboard(TransactionablesCreationViewController.self) { (r, c) in
            c.viewModel = r.resolve(TransactionablesCreationViewModel.self)
        }
        
        // SubscriptionViewController
        container.registerForSkrudzhStoryboard(SubscriptionViewController.self) { (r, c) in
            c.viewModel = r.resolve(SubscriptionViewModel.self)
        }
        
        // PasscodeViewController
        container.registerForSkrudzhStoryboard(PasscodeViewController.self) { (r, c) in
            c.biometricVerificationManager = r.resolve(BiometricVerificationManagerProtocol.self)
        }
        
        // CountriesViewController
        container.registerForSkrudzhStoryboard(CountriesViewController.self) { (r, c) in
            c.viewModel = r.resolve(CountriesViewModel.self)
        }
    }
}
