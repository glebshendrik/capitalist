//
//  AuthenticationServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProviderSession {
    var provider: AuthProvider { get }
    var email: String? { get }
    var userId: String { get }
    var accessToken: String { get }
}

enum AuthProvider : String {
    case VK, FB
    
    var name: String {
        return self.rawValue
    }
}

protocol AuthenticationServiceProtocol {
    func authenticate(email: String, password: String) -> Promise<Session>
    func authenticate(provider: AuthProvider, providerUserId: String) -> Promise<Session>
    func destroy(session: Session) -> Promise<Void>
}
