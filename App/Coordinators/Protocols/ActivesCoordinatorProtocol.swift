//
//  ActivesCoordinatorProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ActivesCoordinatorProtocol {
    func indexActiveTypes() -> Promise<[ActiveType]>
    func indexActives(for basketType: BasketType) -> Promise<[Active]>
    func indexUserActives() -> Promise<[Active]>
    func first(for basketType: BasketType) -> Promise<Active?>
    func createActive(with creationForm: ActiveCreationForm) -> Promise<Active>
    func showActive(by id: Int) -> Promise<Active>
    func updateActive(with updatingForm: ActiveUpdatingForm) -> Promise<Void>
    func updatePosition(with updatingForm: ActivePositionUpdatingForm) -> Promise<Void>
    func destroyActive(by id: Int, deleteTransactions: Bool) -> Promise<Void>
}
