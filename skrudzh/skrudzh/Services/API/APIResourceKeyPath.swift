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
        case .createPasswordResetCode:
            return ResourceKeyPath(singular: "password_reset_code", plural: "password_reset_codes")
        case .createSession,
             .destroySession:
            return ResourceKeyPath(singular: "session", plural: "sessions")
        case .createIncomeSource,
             .showIncomeSource,
             .indexIncomeSources,
             .updateIncomeSource,
             .destroyIncomeSource:
            return ResourceKeyPath(singular: "income_source", plural: "income_sources")
        case .createExpenseSource,
             .showExpenseSource,
             .indexExpenseSources,
             .updateExpenseSource,
             .destroyExpenseSource:
            return ResourceKeyPath(singular: "expense_source", plural: "expense_sources")
        case .indexIcons:
            return ResourceKeyPath(singular: "icon", plural: "icons")
        case .indexBaskets,
             .showBasket:
            return ResourceKeyPath(singular: "basket", plural: "baskets")
        }
    }
}
