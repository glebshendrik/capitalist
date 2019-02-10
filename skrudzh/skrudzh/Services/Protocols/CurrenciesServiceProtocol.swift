//
//  CurrenciesServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol CurrenciesServiceProtocol {
    func index() -> Promise<[Currency]>
}
