//
//  APIResourceKeyPath.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire

struct ResourceKeyPath {
    let singular: String
    let plural: String
}

struct APIResourceKeyPath {
    static func keyPath(for resource: APIResource) -> ResourceKeyPath {
        switch resource {
        case .createUser,
             .showUser,
             .updateUser,
             .changePassword,
             .resetPassword,
             .registerDeviceToken:
            return ResourceKeyPath(singular: "user", plural: "users")
        case .createConfirmationCode:
            return ResourceKeyPath(singular: "confirmation_code", plural: "confirmation_codes")
        case .createSession,
             .destroySession(_):
            return ResourceKeyPath(singular: "session", plural: "sessions")
        }
    }
}
