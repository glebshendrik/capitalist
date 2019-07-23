//
//  APIResourceRequest.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct APIResourceRequest {
    static func urlRequest(for resource: APIResource) throws -> URLRequest {
        
        let url = try APIResource.baseURLString.asURL().appendingQueryParameters(resource.urlStringQueryParameters)
        
        let payload = try self.payload(for: resource)
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(resource.path))
        
        urlRequest.httpMethod = resource.method.rawValue
                
        return try jsonEncoding(of: urlRequest, for: resource, payload: payload)
    }
    
    private static func jsonEncoding(of urlRequest: URLRequest,
                                     for resource: APIResource,
                                     payload: [String : Any?]?) throws -> URLRequest {
        guard let payload = payload else {
            return urlRequest
        }
        return try JSONEncoding.default.encode(urlRequest, with: [resource.keyPath.singular : payload])
    }
    
    private static func payload(for resource: APIResource) throws -> [String : Any?]? {
        switch resource {
        case .createUser(let form):                         return try encode(form)
        case .updateUser(let form):                         return try encode(form)
        case .updateUserSettings(let form):                 return try encode(form)
        case .changePassword(let form):                     return try encode(form)
        case .resetPassword(let form):                      return try encode(form)
        case .createPasswordResetCode(let form):            return try encode(form)
        case .createSession(let form):                      return try encode(form)
        case .updateDeviceToken(let form):      	        return try encode(form)
        case .createIncomeSource(let form):                 return try encode(form)
        case .updateIncomeSource(let form):                 return try encode(form)
        case .updateIncomeSourcePosition(let form):         return try encode(form)
        case .createExpenseSource(let form):                return try encode(form)
        case .updateExpenseSource(let form):                return try encode(form)
        case .updateExpenseSourcePosition(let form):        return try encode(form)
        case .createExpenseCategory(let form):              return try encode(form)
        case .updateExpenseCategory(let form):              return try encode(form)
        case .updateExpenseCategoryPosition(let form):      return try encode(form)
        case .createIncome(let form, _):                    return try encode(form)
        case .updateIncome(let form):                       return try encode(form)
        case .createExpense(let form):                      return try encode(form)
        case .updateExpense(let form):                      return try encode(form)
        case .createFundsMove(let form):                    return try encode(form)
        case .updateFundsMove(let form):                    return try encode(form)
        case .createProviderConnection(let form):           return try encode(form)
        default:                                            return nil
        }
    }
    
    private static func encode<T>(_ encodable: T) throws -> [String : Any]? where T : Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        
        if  let validatable = encodable as? Validatable,
            let errors = validatable.validate() {
            
            throw ValidationError.invalid(errors: errors)
        }
        
        return try encoder.encodeJSONObject(encodable)
    }
}
