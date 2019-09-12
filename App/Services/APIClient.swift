//
//  APIClient.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
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

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid date: " + string)
        }
        return date
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: $0))
    }
}

class APIClient : APIClientProtocol {
    private let userSessionManager: UserSessionManagerProtocol!
    
    init(userSessionManager: UserSessionManagerProtocol) {
        self.userSessionManager = userSessionManager
    }
    
    func request<T>(_ resource: APIRoute) -> Promise<T> where T : Decodable {
        return performRequest(resource).map { (json, _) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            if  let jsonDictionary = json as? [String : Any],
                let objectDictionary = jsonDictionary[resource.resource.singular] as? [String : Any],
                let object = try? decoder.decode(T.self, withJSONObject: objectDictionary) {
                return object
            }
            throw APIRequestError.mappingFailed
        }
    }
    
    func requestCollection<T>(_ resource: APIRoute) -> Promise<[T]> where T : Decodable {
        return self.request(resource).map { (array, _) in
            return array
        }
    }
    
    func request<T>(_ resource: APIRoute) -> Promise<([T], Int?)> where T : Decodable {
        return performRequest(resource).map { (json, response) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            
            if  let jsonDictionary = json as? [String : Any],
                let arrayOfDictionaries = jsonDictionary[resource.resource.plural] as? [[String : Any]],
                let objects = try? decoder.decode([T].self, withJSONObject: arrayOfDictionaries) {
                
                let totalCount = (response.response?.allHeaderFields["Items_total_count"] as? String)?.int
                return (objects, totalCount)
            }
            throw APIRequestError.mappingFailed
        }
    }
    
    func request(_ resource: APIRoute) -> Promise<Void> {
        return performRequest(resource).asVoid()
    }
    
    func request(_ resource: APIRoute) -> Promise<[String : Any]> {
        return performRequest(resource).map { (json, _) in
            if  let jsonDictionary = json as? [String : Any] {
                
                return jsonDictionary
            }
            throw APIRequestError.mappingFailed
        }
    }
    
    private func performRequest(_ resource: APIRoute) -> Promise<(json: Any, response: PMKAlamofireDataResponse)> {
        
        do {
            var request = try resource.asURLRequest()
            if let authToken = self.userSessionManager.currentSession?.token {
                request.addValue("Token token=\(authToken)",
                    forHTTPHeaderField: "Authorization")
            }
            return Alamofire
                .request(request)
                .validate(requestValidator)
                .responseJSON()
        } catch {
            return Promise(error: error)
        }
    }
    
    private func requestValidator(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        
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
                    var errorMessages = [String : String]()
                    if let errorsMessages = try JSONSerialization.jsonObject(with: validData) as? [String : [String]] {
                        
                        
                        errorsMessages.forEach { (attr, messages) in
                            var errorsMessage = messages.reduce("") {combinedMessage, message in "\(combinedMessage) \(message),"}
                            
                            errorsMessage.remove(at: errorsMessage.startIndex)
                            errorsMessage.remove(at: errorsMessage.index(before: errorsMessage.endIndex))
                            
                            errorMessages[attr] = errorsMessage
                        }

                    } else if let errorsMessage = try JSONSerialization.jsonObject(with: validData) as? [String : String] {
                        
                        errorMessages = errorsMessage

                    } else {
                        errorMessages["error"] = "Ошибка сервера"
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
