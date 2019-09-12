//
//  AuthenticationService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class AuthenticationService : Service, AuthenticationServiceProtocol {
    
    func authenticate(form: SessionCreationForm) -> Promise<Session> {
        return request(APIRoute.createSession(form: form))
    }
        
    func destroy(session: Session) -> Promise<Void> {
        return request(APIRoute.destroySession(session: session))
    }
    
}
