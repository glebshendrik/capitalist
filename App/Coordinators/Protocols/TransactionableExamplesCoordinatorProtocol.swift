//
//  TransactionableExamplesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol TransactionableExamplesCoordinatorProtocol {
    func indexBy(_ transactioableType: TransactionableType, basketType: BasketType?, isUsed: Bool) -> Promise<[TransactionableExample]>
}
