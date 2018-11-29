//
//  AuthenticationServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol AuthenticationServiceProtocol {
    func authenticate(email: String, password: String) -> Promise<Session>
    func destroy(session: Session) -> Promise<Void>
}
