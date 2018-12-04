//
//  APIResource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDate

enum APIResource: URLRequestConvertible {
    static var baseURLString: String {
        #if DEBUG
            return "https://skrudzh-staging.herokuapp.com"
        #else
            return "https://skrudzh-production.herokuapp.com"
        #endif
    }
    
    // Users
    case createUser(form: UserCreationForm)
    case showUser(id: Int)
    case updateUser(form: UserUpdatingForm)
    case changePassword(form: ChangePasswordForm)
    case resetPassword(form: ResetPasswordForm)
    case createConfirmationCode(email: String)
    case registerDeviceToken(deviceToken: String, userId: Int)
    
    // Sessions
    case createSession(form: SessionCreationForm)
    case destroySession(session: Session)
    
    var method: HTTPMethod {
        return APIResourceMethod.method(for: self)
    }
    
    var path: String {
        return APIResourcePath.path(for: self)
    }
    
    var keyPath: ResourceKeyPath {
        return APIResourceKeyPath.keyPath(for: self)
    }
    
    var urlStringQueryParameters: [String : String] {
        return APIResourceQueryParameters.queryParameters(for: self)
    }
    
    // MARK: URLRequestConvertible    
    func asURLRequest() throws -> URLRequest {
        return try APIResourceRequest.urlRequest(for: self)
    }
}
