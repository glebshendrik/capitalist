//
//  CreditTypesServiceProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol CreditTypesServiceProtocol {
    func indexCreditTypes() -> Promise<[CreditType]>
}
