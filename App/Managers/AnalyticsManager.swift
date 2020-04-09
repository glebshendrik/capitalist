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
import MyTrackerSDK

class AnalyticsManager : AnalyticsManagerProtocol {    
    func setup() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        MRMyTracker.setupTracker("86955137780758326245")
    }
        
    func set(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
        Analytics.setUserID(userId)
        AppEvents.userID = userId
        MRMyTracker.trackerParams().customUserId = userId
    }
    
    func track(event: String, parameters: [String : Any]?) {
        Analytics.logEvent(event, parameters: parameters)
        AppEvents.logEvent(AppEvents.Name(event), parameters: parameters ?? [:])
        MRMyTracker.trackEvent(withName: event, eventParams: parameters?.compactMapValues { "\($0)" })
    }
}
