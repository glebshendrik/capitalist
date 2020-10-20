//
//  APIRouteRequest.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire

struct APIRouteRequest {
    static func urlRequest(for route: APIRoute) throws -> URLRequest {
        
        let url = try APIRoute.baseURLString.asURL().appendingQueryParameters(route.urlStringQueryParameters)
        
        let payload = try self.payload(for: route)
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(route.path))
        
        urlRequest.httpMethod = route.method.rawValue
                
        return try jsonEncoding(of: urlRequest, for: route, payload: payload)
    }
    
    private static func jsonEncoding(of urlRequest: URLRequest,
                                     for route: APIRoute,
                                     payload: [String : Any?]?) throws -> URLRequest {
        guard let payload = payload else {
            return urlRequest
        }        
        return try JSONEncoding.default.encode(urlRequest, with: [route.resource.singular : payload])
    }
    
    private static func payload(for route: APIRoute) throws -> [String : Any?]? {
        switch route {
        case .createUser(let form):                             return try encode(form)
        case .updateUser(let form):                             return try encode(form)
        case .updateUserSettings(let form):                     return try encode(form)
        case .updateUserSubscription(let form):                 return try encode(form)
        case .changePassword(let form):                         return try encode(form)
        case .resetPassword(let form):                          return try encode(form)
        case .createPasswordResetCode(let form):                return try encode(form)
        case .createSession(let form):                          return try encode(form)
        case .updateDeviceToken(let form):      	            return try encode(form)
        case .createIncomeSource(let form):                     return try encode(form)
        case .updateIncomeSource(let form):                     return try encode(form)
        case .updateIncomeSourcePosition(let form):             return try encode(form)
        case .createExpenseSource(let form):                	return try encode(form)
        case .updateExpenseSource(let form):                    return try encode(form)
        case .updateExpenseSourcePosition(let form):            return try encode(form)
        case .updateExpenseSourceMaxFetchInterval(let form):    return try encode(form)
        case .createExpenseCategory(let form):                  return try encode(form)
        case .updateExpenseCategory(let form):                  return try encode(form)
        case .updateExpenseCategoryPosition(let form):          return try encode(form)
        case .createTransaction(let form):                      return try encode(form)
        case .updateTransaction(let form):                      return try encode(form)
        case .createConnection(let form):                       return try encode(form)
        case .updateConnection(let form):                       return try encode(form)
        case .createDebt(let form):                             return try encode(form)
        case .updateDebt(let form):                             return try encode(form)
        case .createLoan(let form):                             return try encode(form)
        case .updateLoan(let form):                             return try encode(form)
        case .createCredit(let form):                       	return try encode(form)
        case .updateCredit(let form):                       	return try encode(form)
        case .createActive(let form):                       	return try encode(form)
        case .updateActive(let form):                       	return try encode(form)
        case .updateActivePosition(let form):                   return try encode(form)
        default:                                                return nil
        }
    }
    
    private static func encode<T>(_ encodable: T) throws -> [String : Any]? where T : Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        
        if  let validatable = encodable as? Validatable,
            let errors = validatable.validate(),
            !errors.isEmpty {
            
            throw ValidationError.invalid(errors: errors)
        }
        
        return try encoder.encodeJSONObject(encodable)
    }
}
