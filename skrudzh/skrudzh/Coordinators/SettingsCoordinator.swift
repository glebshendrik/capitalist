//
//  SettingsCoordinator.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 08/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class SettingsCoordinator : SettingsCoordinatorProtocol {
    private let usersService: UsersServiceProtocol
    
    init(usersService: UsersServiceProtocol) {
        self.usersService = usersService
    }
    
    func updateUserSettings(with settingsForm: UserSettingsUpdatingForm) -> Promise<Void> {
        return usersService.updateUserSettings(with: settingsForm)
    }
    
    
}
