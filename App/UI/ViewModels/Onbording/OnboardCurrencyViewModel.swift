//
//  OnboardCurrencyViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.11.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class OnboardCurrencyViewModel {
    private let accountCoordinator: AccountCoordinatorProtocol
    private let settingsCoordinator: SettingsCoordinatorProtocol
    
    private var currentUser: User? = nil
    
    var title: String {
        return NSLocalizedString("Выберите валюту", comment: "")
    }
    
    var subtitle: String {
        return NSLocalizedString("Мы используем выбранную валюту, чтобы создать для вас популярные источники доходов и категории трат. Также эта валюта станет валютой по умолчанию для отображения статистических данных. Ее можно будет изменить в настройках в любое время.",
                                 comment: "")
    }
          
    var canOnboardUser: Bool {
        return !isCurrencyUpdating && selectedCurrency != nil
    }
    
    var saveButtonEnabled: Bool {
        return canOnboardUser
    }
       
    var selectedCurrency: Currency? {
        return currentUser?.currency
    }
        
    var currencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var currencySymbol: String? {
        return selectedCurrency?.symbol
    }
    
    var isCurrencyUpdating: Bool = true
    
    init(accountCoordinator: AccountCoordinatorProtocol,
         settingsCoordinator: SettingsCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
        self.settingsCoordinator = settingsCoordinator
    }
      
    func loadData() -> Promise<Void> {
        return update(currencyCode: Locale.current.currencyCode)
    }
    
    func update(currencyCode: String?) -> Promise<Void> {
        return
            firstly {
                updateUserSettings(currencyCode: currencyCode)
            }.then {
                self.loadUser()
            }
    }
    
    func onboardUser() -> Promise<Void> {
        guard
            canOnboardUser
        else {
            return Promise.value(())
        }
        return accountCoordinator.onboardCurrentUser()
    }
    
    private func loadUser() -> Promise<Void> {
        return
            firstly {
                accountCoordinator.loadCurrentUser()
            }.get { user in
                self.currentUser = user
            }.asVoid()
    }
    
    private func updateUserSettings(currencyCode: String?) -> Promise<Void> {
        isCurrencyUpdating = true
        let form = UserSettingsUpdatingForm(userId: accountCoordinator.currentSession?.userId,
                                            currency: currencyCode,
                                            defaultPeriod: nil)
        return
            firstly {
                settingsCoordinator.updateUserSettings(with: form)
            }.ensure {
                self.isCurrencyUpdating = false
            }
    }
}
