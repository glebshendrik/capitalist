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
        case SubscriptionViewController
        case StartAnimationViewController
        
        // Main
        case MainViewController
        case MenuViewController
        case MenuNavigationController
        
        // Income Sources
        case IncomeSourceEditViewController
        case IncomeSourceEditNavigationController
        case IncomeSourceSelectViewController
        case IncomeSourceInfoViewController
        case IncomeSourcesViewController
        
        // Expense Sources
        case ExpenseSourceEditNavigationController
        case ExpenseSourceEditViewController
        case ExpenseSourceSelectViewController
        case ExpenseSourcesViewController
        case ExpenseSourceInfoViewController
        case BankConnectionViewController
        case ProvidersViewController
        case ProviderConnectionViewController
        case AccountsViewController
        case CardTypesViewController
        
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
        case ActivesViewController
        
        // Common
        case IconsViewController
        case CurrenciesViewController
        case SlideUpContainerViewController
        case ReminderEditNavigationController
        case ReminderEditViewController
        case EntityInfoViewController
        case AppUpdateViewController
        case PasscodeViewController
        case CountriesViewController
        
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
        case TransactionablesCreationViewController
        case TransactionCreationInfoViewController
        
        // Statistics
        case StatisticsViewController
        case FiltersSelectionViewController
        case FiltersSelectionNavigationViewController
        case DatePeriodSelectionNavigationController
        case DatePeriodSelectionViewController
        
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
                 .ResetPasswordViewController,
                 .SubscriptionViewController,
                 .StartAnimationViewController:
                return .Join
            case .MainViewController,
                 .MenuViewController,
                 .MenuNavigationController:
                return .Main
            case .IncomeSourceEditViewController,
                 .IncomeSourceEditNavigationController,
                 .IncomeSourceSelectViewController,
                 .IncomeSourceInfoViewController,
                 .IncomeSourcesViewController:
                return .IncomeSources
            case .ExpenseSourceEditNavigationController,
                 .ExpenseSourceEditViewController,
                 .ExpenseSourceSelectViewController,
                 .ExpenseSourceInfoViewController,
                 .BankConnectionViewController,
                 .ProvidersViewController,
                 .ProviderConnectionViewController,
                 .AccountsViewController,
                 .ExpenseSourcesViewController,
                 .CardTypesViewController:
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
                 .EntityInfoViewController,
                 .AppUpdateViewController,
                 .PasscodeViewController,
                 .CountriesViewController:
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
                 .OnboardingPage8ViewController,
                 .TransactionablesCreationViewController,
                 .TransactionCreationInfoViewController:
                return .Onboarding
            case .SettingsViewController:
                return .Settings
            case .StatisticsViewController,
                 .FiltersSelectionViewController,
                 .FiltersSelectionNavigationViewController,
                 .DatePeriodSelectionNavigationController,
                 .DatePeriodSelectionViewController:
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
                 .ActiveInfoViewController,
                 .ActivesViewController:
                return .Actives
            }
        }
    }
}
