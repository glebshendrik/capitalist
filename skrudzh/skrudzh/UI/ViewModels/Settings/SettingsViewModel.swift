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
    var currency: String? {
        return user?.currency.code
    }    
}
