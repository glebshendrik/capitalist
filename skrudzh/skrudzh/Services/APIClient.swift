//
//  APIClient.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwifterSwift

enum APIRequestError: Error {
    case sendingFailed
    case mappingFailed
    case notAuthorized
    case forbidden
    case notFound
    case methodNotAllowed
    case unprocessedEntity(errors: [String : String])
    case locked
    case noConnection
    case timedOut
    case upgradeRequired
}

class APIClient : APIClientProtocol {
    private let userSessionManager: UserSessionManagerProtocol!
    
    init(userSessionManager: UserSessionManagerProtocol) {
        self.userSessionManager = userSessionManager
    }
    
    func request<T>(_ resource: APIResource) -> Promise<T> where T : Mappable {
        return performRequest(resource).then { (json, _) in
            if  let jsonDictionary = json as? [String : Any],
                let objectDictionary = jsonDictionary[resource.keyPath.singular] as? [String : Any],
                let object = T(JSON: objectDictionary) {
                return Promise(value: object)
            }
            return Promise(error: APIRequestError.mappingFailed)
        }
    }
    
    func request<T>(_ resource: APIResource) -> Promise<[T]> where T : Mappable {
        return self.request(resource).then { (array, _) in
            return Promise(value: array)
        }
    }
    
    func request<T>(_ resource: APIResource) -> Promise<([T], Int?)> where T : Mappable {
        return performRequest(resource).then { (json, response) -> Promise<([T], Int?)> in
            if  let jsonDictionary = json as? [String : Any],
                let arrayOfDictionaries = jsonDictionary[resource.keyPath.plural] as? [[String : Any]] {
                
                let objects = Mapper<T>().mapArray(JSONArray: arrayOfDictionaries)
                let totalCount = (response.response?.allHeaderFields["Items_total_count"] as? String)?.int
                return Promise(value: (objects, totalCount))
            }
            return Promise(error: APIRequestError.mappingFailed)
        }
    }
    
    func request(_ resource: APIResource) -> Promise<Void> {
        return performRequest(resource).asVoid()
    }
    
    func request(_ resource: APIResource) -> Promise<[String : Any]> {
        return performRequest(resource).then { (json, _) -> Promise<[String : Any]> in
            if  let jsonDictionary = json as? [String : Any] {
                
                return Promise(value: jsonDictionary)
            }
            return Promise(error: APIRequestError.mappingFailed)
        }
    }
    
    fileprivate func performRequest(_ resource: APIResource) -> Promise<(Any, PMKDataResponse)> {
        
        guard var request = try? resource.asURLRequest() else {
            return Promise(error: APIRequestError.sendingFailed)
        }
        
        if let authToken = userSessionManager.currentSession?.token {
            request.addValue("Token token=\(authToken)",
                forHTTPHeaderField: "Authorization")
        }
        
        //        request.timeoutInterval = 10
        
        return Alamofire
            .request(request)
            .validate(requestValidator)
            .responseJSON(with: .response)
            .recover { error -> (Any, PMKDataResponse) in
                switch (error as NSError).code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    throw APIRequestError.noConnection
                case NSURLErrorTimedOut:
                    throw APIRequestError.timedOut
                default:
                    throw error
                }
        }
    }
    
    fileprivate func requestValidator(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        
        switch response.statusCode {
        case 401:
            return .failure(APIRequestError.notAuthorized)
        case 403:
            return .failure(APIRequestError.forbidden)
        case 404:
            return .failure(APIRequestError.notFound)
        case 405:
            return .failure(APIRequestError.methodNotAllowed)
        case 422:
            if let validData = data {
                do {
                    let errors = try JSONSerialization.jsonObject(with: validData) as! [String : [String]]
                    var errorMessages = [String : String]()
                    errors.forEach { (attr, messages) in
                        var errorsMessage = messages.reduce("") {combinedMessage, message in "\(combinedMessage) \(message),"}
                        
                        errorsMessage.remove(at: errorsMessage.startIndex)
                        errorsMessage.remove(at: errorsMessage.index(before: errorsMessage.endIndex))
                        
                        errorMessages[attr] = errorsMessage
                    }
                    return .failure(APIRequestError.unprocessedEntity(errors: errorMessages))
                } catch {
                    return .failure(
                        AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
                }
            }
            return .failure(APIRequestError.unprocessedEntity(errors: [:]))
        case 423:
            return .failure(APIRequestError.locked)
        case 426:
            return .failure(APIRequestError.upgradeRequired)
            
        default: return .success
        }
    }
    
}
