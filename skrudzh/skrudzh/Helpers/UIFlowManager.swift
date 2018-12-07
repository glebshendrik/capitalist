//
//  UIFlowManager.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

class UIFlowManager {
    
    static var isFirstAppLaunch: Bool {
        return !reachedPoint(key: "com.rubiconapp.skrudzh.first-launch-key")
    }
    
    static var wasShownOnboarding: Bool {
        return reachedPoint(key: "com.rubiconapp.skrudzh.onboarding")
    }
    
    static func reachedPoint(key: String) -> Bool {
        if UserDefaults.standard.bool(forKey: key) {
            return true
        }
        UserDefaults.standard.set(true, forKey: key)
        UserDefaults.standard.synchronize()
        return false
    }
}
