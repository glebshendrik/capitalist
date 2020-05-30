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
import FirebaseMessaging

class AnalyticsManager : AnalyticsManagerProtocol {    
    func setup() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        MRMyTracker.setupTracker("86955137780758326245")
//        Messaging.messaging().isAutoInitEnabled
//        Messaging.messaging().delegate = self
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
    
    func trackSignUp(user: User) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterSignUpMethod: "email"])
        
        AppEvents.logEvent(.completedRegistration)
        AppEvents.setUser(email: user.email, firstName: user.firstname, lastName: user.lastname, phone: nil, dateOfBirth: nil, gender: nil, city: nil, state: nil, zip: nil, country: nil)
        
        MRMyTracker.trackRegistrationEvent()
        MRMyTracker.trackerParams().email = user.email
    }
}
