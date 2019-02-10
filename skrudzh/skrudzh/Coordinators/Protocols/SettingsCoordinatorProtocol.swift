//
//  SettingsCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 08/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol SettingsCoordinatorProtocol {
    func updateUserSettings(with settingsForm: UserSettingsUpdatingForm) -> Promise<Void>
}
