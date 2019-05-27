//
//  SettingsViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class SettingsViewModel : ProfileViewModel {
    private let settingsCoordinator: SettingsCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    private let soundsManager: SoundsManagerProtocol
    
    var currency: String? {
        return user?.currency.code
    }
    
    var period: String? {
        return user?.defaultPeriod.title
    }
    
    var soundsEnabled: Bool {
        return soundsManager.soundsEnabled
    }
    
    init(accountCoordinator: AccountCoordinatorProtocol,
         settingsCoordinator: SettingsCoordinatorProtocol,
         soundsManager: SoundsManagerProtocol) {
        self.accountCoordinator = accountCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.soundsManager = soundsManager
        super.init(accountCoordinator: accountCoordinator)
    }
    
    func setSounds(enabled: Bool) {
        soundsManager.setSounds(enabled: enabled)
    }
    
    func update(currency: Currency) -> Promise<Void> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ProfileEditError.currentSessionDoesNotExist)
        }
        
        let form = UserSettingsUpdatingForm(userId: currentUserId, currency: currency.code, defaultPeriod: nil)
        return update(settings: form)
    }
    
    func update(period: AccountingPeriod) -> Promise<Void> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ProfileEditError.currentSessionDoesNotExist)
        }
        
        let form = UserSettingsUpdatingForm(userId: currentUserId, currency: nil, defaultPeriod: period)
        return update(settings: form)
    }
    
    private func update(settings: UserSettingsUpdatingForm) -> Promise<Void> {
        return  firstly {
                    settingsCoordinator.updateUserSettings(with: settings)
                }.get {
                    
                    NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
                    
                    
                }.then { _ in
                    return self.loadData()
                }
    }
}
