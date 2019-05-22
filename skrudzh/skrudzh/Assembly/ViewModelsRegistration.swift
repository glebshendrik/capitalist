//
//  ViewModelsRegistration.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 20/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Swinject
import SwinjectStoryboard
import SwinjectAutoregistration

extension ApplicationAssembly {
            
    func registerViewModels(in container: Container) {

        container.autoregister(MenuViewModel.self, initializer: MenuViewModel.init)
        
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
        
        container.autoregister(IncomeEditViewModel.self, initializer: IncomeEditViewModel.init)
        
        container.autoregister(ExpenseEditViewModel.self, initializer: ExpenseEditViewModel.init)
        
        container.autoregister(FundsMoveEditViewModel.self, initializer: FundsMoveEditViewModel.init)
        
        container.autoregister(IncomeSourcesViewModel.self, initializer: IncomeSourcesViewModel.init)
        
        container.autoregister(ExpenseSourcesViewModel.self, initializer: ExpenseSourcesViewModel.init)
        
        container.autoregister(ExpenseCategoriesViewModel.self, initializer: ExpenseCategoriesViewModel.init)
        
        container.autoregister(StatisticsViewModel.self, initializer: StatisticsViewModel.init)
        
        container.autoregister(HistoryTransactionsViewModel.self, initializer: HistoryTransactionsViewModel.init)
        
        container.autoregister(FiltersViewModel.self, initializer: FiltersViewModel.init)
        
        container.autoregister(FiltersSelectionViewModel.self, initializer: FiltersSelectionViewModel.init)
        
        container.autoregister(WaitingDebtsViewModel.self, initializer: WaitingDebtsViewModel.init)
        
        container.autoregister(BalanceViewModel.self, initializer: BalanceViewModel.init)
    }
}