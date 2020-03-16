//
//  AnalyticsManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit

class AnalyticsManager : AnalyticsManagerProtocol {    
    func setup() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max)        
    }
        
    func set(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
        Analytics.setUserID(userId)
        AppEvents.userID = userId
    }
    
    func track(event: String, parameters: [String : Any]?) {
        Analytics.logEvent(event, parameters: parameters)
    }
}
