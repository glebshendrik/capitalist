//
//  AccountConnectionsServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol AccountConnectionsServiceProtocol {
    func index(for userId: Int, connectionId: String) -> Promise<[AccountConnection]>
    func destroy(by accountConnectionId: Int) -> Promise<Void>
}
