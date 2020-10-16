//
//  ViewModelsRegistration.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Swinject
import SwinjectStoryboard
import SwinjectAutoregistration

extension ApplicationAssembly {
            
    func registerViewModels(in container: Container) {

        container.autoregister(MenuViewModel.self, initializer: MenuViewModel.init)        .inObjectScope(.container)
        
        container.autoregister(RegistrationViewModel.self, initializer: RegistrationViewModel.init)
        
        container.autoregister(ProfileViewModel.self, initializer: ProfileViewModel.init)

        container.autoregister(LoginViewModel.self, initializer: LoginViewModel.init)

        container.autoregister(ForgotPasswordViewModel.self, initializer: ForgotPasswordViewModel.init)

        container.autoregister(ResetPasswordViewModel.self, initializer: ResetPasswordViewModel.init)

        container.autoregister(ChangePasswordViewModel.self, initializer: ChangePasswordViewModel.init)

        container.autoregister(ProfileEditViewModel.self, initializer: ProfileEditViewModel.init)

        container.autoregister(MainViewModel.self, initializer: MainViewModel.init)

        container.autoregister(IncomeSourceEditViewModel.self, initializer: IncomeSourceEditViewModel.init)

        container.autoregister(ExpenseSourceEditViewModel.self, initializer: ExpenseSourceEditViewModel.init)

        container.autoregister(IconsViewModel.self, initializer: IconsViewModel.init)

        container.autoregister(ExpenseCategoryEditViewModel.self, initializer: ExpenseCategoryEditViewModel.init)

        container.autoregister(SettingsViewModel.self, initializer: SettingsViewModel.init)
        
        container.autoregister(CurrenciesViewModel.self, initializer: CurrenciesViewModel.init)
        
        container.autoregister(TransactionEditViewModel.self, initializer: TransactionEditViewModel.init)
        
        container.autoregister(IncomeSourcesViewModel.self, initializer: IncomeSourcesViewModel.init)
        
        container.autoregister(ExpenseSourcesViewModel.self, initializer: ExpenseSourcesViewModel.init)
        
        container.autoregister(ExpenseCategoriesViewModel.self, initializer: ExpenseCategoriesViewModel.init)
        
        container.autoregister(StatisticsViewModel.self, initializer: StatisticsViewModel.init)
        
        container.autoregister(TransactionsViewModel.self, initializer: TransactionsViewModel.init)
        
        container.autoregister(FiltersViewModel.self, initializer: FiltersViewModel.init)
        
        container.autoregister(FiltersSelectionViewModel.self, initializer: FiltersSelectionViewModel.init)
        
        container.autoregister(WaitingBorrowsViewModel.self, initializer: WaitingBorrowsViewModel.init)
        
        container.autoregister(BalanceViewModel.self, initializer: BalanceViewModel.init)
        
        container.autoregister(ProvidersViewModel.self, initializer: ProvidersViewModel.init)
        
        container.autoregister(AccountsViewModel.self, initializer: AccountsViewModel.init)
        
        container.autoregister(BorrowsViewModel.self, initializer: BorrowsViewModel.init)
        
        container.autoregister(BorrowEditViewModel.self, initializer: BorrowEditViewModel.init)
        
        container.autoregister(CreditsViewModel.self, initializer: CreditsViewModel.init)
        
        container.autoregister(CreditEditViewModel.self, initializer: CreditEditViewModel.init)
        
        container.autoregister(ActiveEditViewModel.self, initializer: ActiveEditViewModel.init)
        
        container.autoregister(ActivesViewModel.self, initializer: ActivesViewModel.init)
        
        container.autoregister(IncomeSourceInfoViewModel.self, initializer: IncomeSourceInfoViewModel.init)
        
        container.autoregister(ExpenseSourceInfoViewModel.self, initializer: ExpenseSourceInfoViewModel.init)
        
        container.autoregister(ExpenseCategoryInfoViewModel.self, initializer: ExpenseCategoryInfoViewModel.init)
        
        container.autoregister(ActiveInfoViewModel.self, initializer: ActiveInfoViewModel.init)
        
        container.autoregister(CreditInfoViewModel.self, initializer: CreditInfoViewModel.init)
        
        container.autoregister(BorrowInfoViewModel.self, initializer: BorrowInfoViewModel.init)
        
        container.autoregister(DatePeriodSelectionViewModel.self, initializer: DatePeriodSelectionViewModel.init)
        
        container.autoregister(PeriodsViewModel.self, initializer: PeriodsViewModel.init)
                
        container.autoregister(TransactionablesCreationViewModel.self, initializer: TransactionablesCreationViewModel.init)
        
        container.autoregister(SubscriptionViewModel.self, initializer: SubscriptionViewModel.init)
        
        container.autoregister(ProviderConnectionViewModel.self, initializer: ProviderConnectionViewModel.init)
        
        container.autoregister(CountriesViewModel.self, initializer: CountriesViewModel.init)
        
        container.autoregister(CardTypesViewModel.self, initializer: CardTypesViewModel.init)
        
        container.autoregister(TransactionableExamplesViewModel.self, initializer: TransactionableExamplesViewModel.init)        
    }
}
