//
//  NotificationsCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import PromiseKit

protocol NotificationsCoordinatorProtocol : NotificationsManagerProtocol {
    func register(deviceToken: Data) -> Promise<Void>
    func updateBadges()
}
