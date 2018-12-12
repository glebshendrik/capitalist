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
             .createPasswordResetCode,
             .createIncomeSource:
            return .post
        case .showUser,
             .showIncomeSource,
             .indexIncomeSources:
            return .get
        case .updateUser,
             .changePassword,
             .resetPassword,
             .registerDeviceToken,
             .updateIncomeSource:
            return .put
        case .destroySession,
             .destroyIncomeSource:
            return .delete
        }
    }
}
