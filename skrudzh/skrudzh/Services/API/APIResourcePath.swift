//
//  APIResourcePath.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct APIResourcePath {
    static func path(for resource: APIResource) -> String {
        switch resource {
        case .createUser:                                   return "/users"
        case .showUser(let id):                             return "/users/\(id)"
        case .updateUser(let form):                         return "/users/\(form.userId)"
        case .changePassword(let form):                     return "/users/\(form.userId)/password"
        case .resetPassword:                                return "/users/new_password"
        case .createPasswordResetCode:                      return "/password_reset_codes"
        case .createSession:                                return "/sessions"
        case .destroySession(let session):                  return "/sessions/\(session.token)"
        case .registerDeviceToken(_, let userId):           return "/users/\(userId)/device_token"
        }
    }
}
