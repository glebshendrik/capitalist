//
//  AnalyticsManagerProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

protocol AnalyticsManagerDependantProtocol {
    var analyticsManager: AnalyticsManagerProtocol! { get set }
}

protocol AnalyticsManagerProtocol {
    func setup()
    func set(userId: String)
    func track(event: String, parameters: [String : Any]?)
}
