//
//  UserSessionManagerProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum SessionError: Error {
    case noSessionInAuthorizedContext
}

protocol UserSessionManagerProtocol {
    var currentSession: Session? { get }
    var isUserAuthenticated: Bool { get }
    
    func save(session: Session)
    func forgetSession()
}
