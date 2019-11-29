//
//  Infrastructure.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Infrastructure {
    
    enum Storyboard : String {
        case Join
        case Main
        case IncomeSources
        case ExpenseSources
        case ExpenseCategories
        case Transactions
        case Common
        case Profile
        case Onboarding
        case Settings
        case Statistics
        case Balance
        case Borrows
        case Credits
        case Actives
        
        var name: String { return self.rawValue }
        
        static func all() -> [Storyboard] {
            return [.Main,
                    .Join,
                    .Profile,
                    .Onboarding,
                    .Settings,
                    .Statistics,
                    .Balance,
                    .Borrows,
                    .Credits,
                    .Actives,
                    .IncomeSources,
                    .ExpenseSources,
                    .ExpenseCategories,
                    .Transactions,
                    .Common]
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
        
        // Income Sources
        case IncomeSourceEditViewController
        case IncomeSourceEditNavigationController
        case IncomeSourceSelectViewController
        case IncomeSourceInfoViewController
        
        // Expense Sources
        case ExpenseSourceEditNavigationController
        case ExpenseSourceEditViewController
        case ExpenseSourceSelectViewController
        case ExpenseSourceInfoViewController
        case BankConnectionViewController
        case ProvidersViewController
        case ProviderConnectionViewController
        case AccountsViewController
        
        // Expense Categories
        case ExpenseCategoryEditNavigationController
        case ExpenseCategoryEditViewController
        case ExpenseCategorySelectViewController
        case ExpenseCategoryInfoViewController
        
        // Transactions
        case TransactionEditNavigationController
        case TransactionEditViewController
        
        // Borrows
        case BorrowsViewController
        case BorrowEditNavigationController
        case BorrowEditViewController
        case WaitingBorrowsViewController
        case BorrowInfoViewController
        
        // Credits
        case CreditsViewController
        case CreditEditNavigationController
        case CreditEditViewController
        case CreditInfoViewController
        
        // Actives
        case ActiveEditNavigationController
        case ActiveEditViewController
        case ActiveSelectViewController
        case DependentIncomeSourceInfoViewController
        case ActiveInfoViewController
        
        // Common
        case IconsViewController
        case CurrenciesViewController
        case SlideUpContainerViewController
        case ReminderEditNavigationController
        case ReminderEditViewController
        case EntityInfoViewController
        
        // Profile
        case ProfileViewController
        case ChangePasswordViewController
        
        // Settings
        case SettingsViewController
        
        // Onboarding
        case OnboardingViewController
        case OnboardingPagesViewController
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
        case FiltersSelectionViewController
        case FiltersSelectionNavigationViewController
        
        // Balance
        case BalanceViewController
        
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
                 .MenuNavigationController:
                return .Main
            case .IncomeSourceEditViewController,
                 .IncomeSourceEditNavigationController,
                 .IncomeSourceSelectViewController,
                 .IncomeSourceInfoViewController:
                return .IncomeSources
            case .ExpenseSourceEditNavigationController,
                 .ExpenseSourceEditViewController,
                 .ExpenseSourceSelectViewController,
                 .ExpenseSourceInfoViewController,
                 .BankConnectionViewController,
                 .ProvidersViewController,
                 .ProviderConnectionViewController,
                 .AccountsViewController:
                return .ExpenseSources
            case .ExpenseCategoryEditNavigationController,
                 .ExpenseCategoryEditViewController,
                 .ExpenseCategorySelectViewController,
                 .ExpenseCategoryInfoViewController:
                return .ExpenseCategories
            case .TransactionEditNavigationController,
                 .TransactionEditViewController:
                return .Transactions
            case .IconsViewController,
                 .CurrenciesViewController,
                 .SlideUpContainerViewController,
                 .ReminderEditNavigationController,
                 .ReminderEditViewController,
                 .EntityInfoViewController:
                return .Common
            case .ProfileViewController,
                 .ChangePasswordViewController:
                return .Profile
            case .OnboardingViewController,
                 .OnboardingPagesViewController,
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
            case .StatisticsViewController,
                 .FiltersSelectionViewController,
                 .FiltersSelectionNavigationViewController:
                return .Statistics
            case .BalanceViewController:
                return .Balance
            case .BorrowsViewController,
                 .BorrowEditNavigationController,
                 .BorrowEditViewController,
                 .WaitingBorrowsViewController,
                 .BorrowInfoViewController:
                return .Borrows
            case .CreditsViewController,
                 .CreditEditNavigationController,
                 .CreditEditViewController,
                 .CreditInfoViewController:
                return .Credits
            case .ActiveEditNavigationController,
                 .ActiveEditViewController,
                 .ActiveSelectViewController,
                 .DependentIncomeSourceInfoViewController,                 
                 .ActiveInfoViewController:
                return .Actives
            }
        }
    }
}
