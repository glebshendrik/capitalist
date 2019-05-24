//
//  CurrenciesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol CurrenciesCoordinatorProtocol {
    func index() -> Promise<[Currency]>
}
