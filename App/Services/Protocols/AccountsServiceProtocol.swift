//
//  AccountConnectionsServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol AccountsServiceProtocol {
    func index(for userId: Int, currencyCode: String?, connectionId: String, providerId: String, notUsed: Bool, nature: AccountNatureType) -> Promise<[Account]>
}
