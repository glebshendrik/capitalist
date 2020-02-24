//
//  AnalyticsManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import Mixpanel

class AnalyticsManager : AnalyticsManagerProtocol {
    init() {
        Mixpanel.initialize(token: "token")
    }
    
    func set(userId: String) {
        Mixpanel.mainInstance().identify(distinctId: userId)
    }
    
    func track(event: String) {
        Mixpanel.mainInstance().track(event: event)
    }
}
