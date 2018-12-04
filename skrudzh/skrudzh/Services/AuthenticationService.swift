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
    
    func authenticate(form: SessionCreationForm) -> Promise<Session> {
        return request(APIResource.createSession(form: form))
    }
        
    func destroy(session: Session) -> Promise<Void> {
        return request(APIResource.destroySession(session: session))
    }
    
}
