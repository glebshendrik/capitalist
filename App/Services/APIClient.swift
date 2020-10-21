//
//  APIClient.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwifterSwift
import SwiftyBeaver

enum APIRequestError: Error {
    case sendingFailed
    case mappingFailed
    case notAuthorized
    case paymentRequired
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
            let error = DecodingError.dataCorruptedError(in: container,
                                                         debugDescription: "Invalid date: " + string)
            SwiftyBeaver.error(error)
            throw error
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
        return performRequest(resource).map { (json, response) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
            
            do {
                if  let jsonDictionary = json as? [String : Any],
                    let objectDictionary = jsonDictionary[resource.resource.singular] as? [String : Any],
                    let object = try? decoder.decode(T.self, withJSONObject: objectDictionary) {
                    return object
                }
                SwiftyBeaver.error(response)
                if let jsonDictionary = json as? [String : Any] {
                    SwiftyBeaver.error(jsonDictionary)
                }
                throw APIRequestError.mappingFailed
            }
            catch {                
                SwiftyBeaver.error(error)
                throw error
            }
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
            
            do {
                if  let jsonDictionary = json as? [String : Any],
                    let arrayOfDictionaries = jsonDictionary[resource.resource.plural] as? [[String : Any]],
                    let objects = try? decoder.decode([T].self, withJSONObject: arrayOfDictionaries) {
                    
                    let totalCount = (response.response?.allHeaderFields["Items_total_count"] as? String)?.int
                    return (objects, totalCount)
                }
                SwiftyBeaver.error(response)
                if let jsonDictionary = json as? [String : Any] {
                    SwiftyBeaver.error(jsonDictionary)
                }
                throw APIRequestError.mappingFailed
            }
            catch {
                SwiftyBeaver.error(error)
                throw error
            }
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
            request.addValue(TimeZone.autoupdatingCurrent.identifier, forHTTPHeaderField: "X-Timezone")
            if let country = Locale.autoupdatingCurrent.regionCode {
                request.addValue(country, forHTTPHeaderField: "X-REGION")
            }
            if let build = UIApplication.shared.buildNumber {
                request.addValue(build, forHTTPHeaderField: "X-iOS-Build")
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
        if response.statusCode >= 500 {
            SwiftyBeaver.error(request?.httpMethod)
            SwiftyBeaver.error(response)
        }
        switch response.statusCode {
        case 401:
            return .failure(APIRequestError.notAuthorized)
        case 402:
            return .failure(APIRequestError.paymentRequired)
        case 403:
            SwiftyBeaver.error(response)
            return .failure(APIRequestError.forbidden)
        case 404:
            SwiftyBeaver.error(response)
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
                        errorMessages["error"] = NSLocalizedString("Common server error", comment: "Common server error message")
                    }
                    return .failure(APIRequestError.unprocessedEntity(errors: errorMessages))
                } catch {
                    SwiftyBeaver.error(request?.httpMethod)
                    SwiftyBeaver.error(response)
                    SwiftyBeaver.error(error)
                    return .failure(
                        AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
                }
            }
            return .failure(APIRequestError.unprocessedEntity(errors: [:]))
        case 423:
            SwiftyBeaver.error(request?.httpMethod)
            SwiftyBeaver.error(response)
            return .failure(APIRequestError.locked)
        case 426:
            SwiftyBeaver.error(request?.httpMethod)
            SwiftyBeaver.error(response)
            return .failure(APIRequestError.upgradeRequired)
        default: return .success
        }
    }
    
}
