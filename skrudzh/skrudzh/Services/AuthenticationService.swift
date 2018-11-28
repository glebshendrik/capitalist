//
//  AuthenticationService.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

class AuthenticationService : Service, AuthenticationServiceProtocol {
    
    func authenticate(email: String, password: String) -> Promise<Session> {
        return request(APIResource.createSession(email: email, password: password))
    }
    
    func authenticate(provider: AuthProvider, providerUserId: String) -> Promise<Session> {
        return request(APIResource.createSessionThroughProvider(provider: provider, providerUserId: providerUserId))
    }
    
    func destroy(session: Session) -> Promise<Void> {
        return request(APIResource.destroySession(session: session))
    }
    
}
