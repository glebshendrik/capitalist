//
//  APIResourceRequest.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire

struct APIResourceRequest {
    static func urlRequest(for resource: APIResource) throws -> URLRequest {
        let url = try APIResource.baseURLString.asURL().appendingQueryParameters(resource.urlStringQueryParameters)
        var urlRequest = URLRequest(url: url.appendingPathComponent(resource.path))
        urlRequest.httpMethod = resource.method.rawValue
        return try jsonEncoding(of: urlRequest, for: resource)
    }
    
    private static func jsonEncoding(of urlRequest: URLRequest,
                                     for resource: APIResource) throws -> URLRequest {
        guard let payload = payload(for: resource) else {
            return urlRequest
        }
        return try JSONEncoding.default.encode(urlRequest, with: [resource.keyPath.singular : payload])
    }
    
    private static func payload(for resource: APIResource) -> [String : Any?]? {
        switch resource {
        case .createUser(let form):                         return encode(form)
        case .updateUser(let form):                         return encode(form)
        case .changePassword(let form):                     return encode(form)
        case .resetPassword(let form):                      return encode(form)
        case .createPasswordResetCode(let form):            return encode(form)
        case .createSession(let form):                      return encode(form)
        case .registerDeviceToken(let deviceToken, _):      return [ "device_token" : deviceToken ]
        case .createIncomeSource(let form):                 return encode(form)
        case .updateIncomeSource(let form):                 return encode(form)
        case .updateIncomeSourcePosition(let form):         return encode(form)
        case .createExpenseSource(let form):                return encode(form)
        case .updateExpenseSource(let form):                return encode(form)
        case .updateExpenseSourcePosition(let form):        return encode(form)
        case .createExpenseCategory(let form):              return encode(form)
        case .updateExpenseCategory(let form):              return encode(form)
        default:                                            return nil
        }
    }
    
    private static func encode<T>(_ encodable: T) -> [String : Any]? where T : Encodable {
        return try? JSONEncoder().encodeJSONObject(encodable)
    }
}
