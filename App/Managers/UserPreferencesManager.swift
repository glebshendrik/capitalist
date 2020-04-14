//
//  UserPreferencesManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class UserPreferencesManager : UserPreferencesManagerProtocol {
    enum Keys : String {
        case fastGesturePressDurationMilliseconds
    }
    
    var fastGesturePressDurationMilliseconds: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.fastGesturePressDurationMilliseconds.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.fastGesturePressDurationMilliseconds.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
