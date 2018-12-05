//
//  APIResourceMethod.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire

struct APIResourceMethod {
    static func method(for resource: APIResource) -> HTTPMethod {
        switch resource {
        case .createUser,
             .createSession,
             .createPasswordResetCode:
            return .post
        case .showUser:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .registerDeviceToken:
            return .put
        case .destroySession:
            return .delete
        }
    }
}
