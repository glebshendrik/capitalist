//
//  BasketsServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol BasketsServiceProtocol {
    func show(by id: Int) -> Promise<Basket>
    func index(for userId: Int) -> Promise<[Basket]>
}
