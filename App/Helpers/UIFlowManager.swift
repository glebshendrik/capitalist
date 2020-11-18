//
//  UIFlowManager.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum UIFlowPoint : String {
    case appLaunch = "com.rubiconapp.skrudzh.first-launch-key"
    case onboarding = "com.rubiconapp.skrudzh.onboarding"
    case subscription
    case dataSetup
    case agreedRules
    case walletsSetup
    case dependentIncomeSourceMessage
    case transactionCreationInfoMessage
    case soundsManagerInitialization
    case verificationManagerInitialization
    case userPreferencesManagerInitialization
    case incomeSourcesTutorial
    case debtsAndCreditsTutorial
    case settingsTutorial
    case statisticsFiltersTutorial
    case statisticsPeriodTutorial
    case bankExperimentalFeature
}

class UIFlowManager {
    
    static var isFirstAppLaunch: Bool {
        return !reach(point: .appLaunch)
    }
    
    static var wasShownOnboarding: Bool {
        return reach(point: .onboarding)
    }
    
    static func reach(point: UIFlowPoint) -> Bool {
        return reachPoint(key: point.rawValue)
    }
    
    static func reachPoint(key: String) -> Bool {
        if UserDefaults.standard.bool(forKey: key) {
            return true
        }
        set(key, reached: true)
        return false
    }
    
    static func set(point: UIFlowPoint, reached: Bool) {
        let key = point.rawValue
        set(key, reached: reached)
    }
    
    static func set(_ key: String, reached: Bool) {
        UserDefaults.standard.set(reached, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func reached(point: UIFlowPoint) -> Bool {
        return UserDefaults.standard.bool(forKey: point.rawValue)
    }
}
