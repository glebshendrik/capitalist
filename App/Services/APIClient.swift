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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXX"
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
            
            guard
                let jsonDictionary = json as? [String : Any],
                let objectDictionary = jsonDictionary[resource.resource.singular] as? [String : Any]
            else {
                self.log(response: response, json: json, errors: [APIRequestError.mappingFailed])
                throw APIRequestError.mappingFailed
            }
            
            do {
                return try decoder.decode(T.self, withJSONObject: objectDictionary)
            }
            catch {
                self.log(response: response, json: json, errors: [APIRequestError.mappingFailed, error])
                throw APIRequestError.mappingFailed
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
            
            guard
                let jsonDictionary = json as? [String : Any],
                let arrayOfDictionaries = jsonDictionary[resource.resource.plural] as? [[String : Any]]
            else {
                self.log(response: response, json: json, errors: [APIRequestError.mappingFailed])
                throw APIRequestError.mappingFailed
            }
            
            do {
                let objects = try decoder.decode([T].self, withJSONObject: arrayOfDictionaries)
                let totalCount = (response.response?.allHeaderFields["Items_total_count"] as? String)?.int
                return (objects, totalCount)
            }
            catch {
                self.log(response: response, json: json, errors: [APIRequestError.mappingFailed, error])
                throw APIRequestError.mappingFailed
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
                        
            log(method: request.httpMethod?.uppercased(),
                url: request.url?.absoluteString,
                statusCode: nil,
                data: request.httpBody?.prettyPrintedJSONString,
                errors: [],
                level: .info)
            
            return Alamofire
                .request(request)
                .validate(requestValidator)
                .responseJSON()
        } catch {
            log(route: resource, errors: [APIRequestError.mappingFailed, error])
            return Promise(error: error)
        }
    }
    
    private func requestValidator(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        if response.statusCode >= 500 {
            log(request: request, response: response)
        }
        switch response.statusCode {
        case 401:
            log(request: request, response: response, errors: [APIRequestError.notAuthorized], level: .warning)
            return .failure(APIRequestError.notAuthorized)
        case 402:
            log(request: request, response: response, errors: [APIRequestError.paymentRequired], level: .warning)
            return .failure(APIRequestError.paymentRequired)
        case 403:
            log(request: request, response: response, errors: [APIRequestError.forbidden], level: .warning)
            return .failure(APIRequestError.forbidden)
        case 404:
            log(request: request, response: response, errors: [APIRequestError.notFound], level: .warning)
            return .failure(APIRequestError.notFound)
        case 405:
            log(request: request, response: response, errors: [APIRequestError.methodNotAllowed], level: .warning)
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
                    log(request: request, response: response, data: errorMessages.description, level: .warning)
                    return .failure(APIRequestError.unprocessedEntity(errors: errorMessages))
                } catch {
                    log(request: request, response: response, errors: [error])
                    return .failure(
                        AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
                }
            }
            log(request: request, response: response, level: .warning)
            return .failure(APIRequestError.unprocessedEntity(errors: [:]))
        case 423:
            log(request: request, response: response, errors: [APIRequestError.locked], level: .warning)
            return .failure(APIRequestError.locked)
        case 426:
            log(request: request, response: response, errors: [APIRequestError.upgradeRequired], level: .warning)
            return .failure(APIRequestError.upgradeRequired)
        default:
            log(request: request, response: response, level: .info)
            return .success
        }
    }
    
    private func log(response: PMKAlamofireDataResponse, json: Any, errors: [Error] = [], level: SwiftyBeaver.Level = .error) {
        log(method: response.request?.httpMethod,
            url: response.request?.url?.absoluteString,
            statusCode: response.response?.statusCode,
            data: (json as? [String : Any])?.debugDescription,
            errors: errors,
            level: level)
    }
    
    private func log(request: URLRequest?, response: HTTPURLResponse, errors: [Error] = [], data: String? = nil, level: SwiftyBeaver.Level = .error) {
        log(method: request?.httpMethod,
            url: request?.url?.absoluteString,
            statusCode: response.statusCode,
            data: data,
            errors: errors,
            level: level)
    }
    
    private func log(route: APIRoute, errors: [Error] = [], level: SwiftyBeaver.Level = .error) {
        log(method: "\(route.method)",
            url: "\(route.path) \(route.urlStringQueryParameters)",
            statusCode: nil,
            data: "\(route)",
            errors: errors,
            level: level)
    }
    
    private func log(method: String?, url: String?, statusCode: Int?, data: String?, errors: [Error], level: SwiftyBeaver.Level) {
        var message = ""
        if let statusCode = statusCode {
            message.append("\(statusCode) ")
        }
        if let method = method,
           let url = url {
            message.append("\(method) \(url)\n")
        }
        errors.forEach {
            message.append("Error: \($0)\n")
        }
                
        if let data = data {
            SwiftyBeaver.custom(level: level, message: message)
            
            let extendedMessage = message.appending("Data: \(data)\n")
            if level == .error {
                SwiftyBeaver.warning(extendedMessage)
            }
            if level == .info {
                SwiftyBeaver.verbose(extendedMessage)
            }
        }
        else {
            SwiftyBeaver.custom(level: level, message: message)
        }
    }
}
