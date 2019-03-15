//
//  SettingsViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
        
        let form = UserSettingsUpdatingForm(userId: currentUserId, currency: currency.code)
        return  firstly {
                    settingsCoordinator.updateUserSettings(with: form)
                }.get {
                    
                    NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
                    
                    
                }.then { _ in
                    return self.loadData()
                }
    }
}
