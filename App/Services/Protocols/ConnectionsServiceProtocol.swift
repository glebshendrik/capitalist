//
//  ProviderConnectionsServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 03/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ConnectionsServiceProtocol {
    func index(for userId: Int, providerId: String) -> Promise<[Connection]>
    func create(with creationForm: ConnectionCreationForm) -> Promise<Connection>
    func show(by id: Int) -> Promise<Connection>
    func update(with updatingForm: ConnectionUpdatingForm) -> Promise<Void>
}
