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
    
    var currency: String? {
        return user?.currency.code
    }
        
    init(accountCoordinator: AccountCoordinatorProtocol,
         settingsCoordinator: SettingsCoordinatorProtocol) {
        self.accountCoordinator = accountCoordinator
        self.settingsCoordinator = settingsCoordinator
        super.init(accountCoordinator: accountCoordinator)
        
    }
    
    func update(currency: Currency) -> Promise<Void> {
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ProfileEditError.currentSessionDoesNotExist)
        }
        
        let form = UserSettingsUpdatingForm(userId: currentUserId, currency: currency.code)
        return  firstly {
                    settingsCoordinator.updateUserSettings(with: form)
                }.then { _ in
                    return self.loadData()
                }
    }
}
