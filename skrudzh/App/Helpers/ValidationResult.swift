//
//  ValidationResult.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

enum ValidationError : Error {
    case invalid(failures: [ValidationResultProtocol])
}

enum ValidationErrorReason {
    case required
    case invalid
    case tooShort
    case tooLong
    case notEqual(to: CodingKey)
}

protocol ValidationResultProtocol {
    var isSucceeded: Bool { get }
    var key: CodingKey { get }
    var failureReasons: [ValidationErrorReason] { get }
}

enum ValidationResult<T> {
    case success(key: CodingKey, value: T)
    case failure(key: CodingKey, reasons: [ValidationErrorReason])
    
    var value: T? {
        switch self {
        case .success(_, let value):
            return value
        case .failure:
            return nil
        }
    }
    
}

extension ValidationResult : ValidationResultProtocol {
    var isSucceeded: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var key: CodingKey {
        switch self {
        case .success(let key, _):
            return key
        case .failure(let key, _):
            return key
        }
    }
    
    var failureReasons: [ValidationErrorReason] {
        switch self {
        case .success:
            return []
        case .failure(_, let reasons):
            return reasons
        }
    }
}

class Validator {
    static func validate(required: String?, key: CodingKey) -> ValidationResult<String> {
        guard let required = required, !required.isEmpty else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        return .success(key: key,
                        value: required)
    }
    
    static func validate(email: String?, key: CodingKey) -> ValidationResult<String> {
        return validate(required: email, key: key)
    }
    
    static func validate(password: String?, key: CodingKey) -> ValidationResult<String> {
        return validate(required: password, key: key)
    }
    
    static func validate(passwordConfirmation: String?,
                         password: String?,
                         passwordConfirmationKey: CodingKey,
                         passwordKey: CodingKey) -> ValidationResult<String> {
        
        let requiredValidationResult = validate(required: passwordConfirmation, key: passwordConfirmationKey)
        if !requiredValidationResult.isSucceeded { return requiredValidationResult }
        
        guard password == passwordConfirmation else {
            return .failure(key: passwordConfirmationKey,
                            reasons: [ValidationErrorReason.notEqual(to: passwordKey)])
        }
        return requiredValidationResult
    }
    
    static func validate(money: Int?, key: CodingKey) -> ValidationResult<Int> {
        guard let money = money else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        guard money >= 0 else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.invalid])
        }
        return .success(key: key,
                        value: money)
    }
    
    static func validate(positiveMoney: Int?, key: CodingKey) -> ValidationResult<Int> {
        guard let money = positiveMoney else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        guard money > 0 else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.invalid])
        }
        return .success(key: key,
                        value: money)
    }
    
    static func validate(balance: Int?, key: CodingKey) -> ValidationResult<Int> {
        guard let money = balance else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        
        return .success(key: key,
                        value: money)
    }
    
    static func validate(pastDate: Date?, key: CodingKey) -> ValidationResult<Date> {
        guard let pastDate = pastDate else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        guard pastDate <= Date() else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.invalid])
        }
        return .success(key: key,
                        value: pastDate)
    }
    
    static func validate(futureDate: Date?, key: CodingKey) -> ValidationResult<Date> {
        guard let futureDate = futureDate else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        guard futureDate >= Date() else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.invalid])
        }
        return .success(key: key,
                        value: futureDate)
    }
    
    static func failureResultsHash<T>(from validationResults: [ValidationResultProtocol]) -> [T : [ValidationErrorReason]]? {
        let failureResults = validationResults.filter { !$0.isSucceeded }
        
        if failureResults.isEmpty { return nil }
        
        let failureResultsHash: [T : [ValidationErrorReason]] =
            failureResults
                .reduce(into: [:]) { hash, failureResult in
                    
                    if let key = failureResult.key as? T {
                        hash[key] = failureResult.failureReasons
                    }
        }
        return failureResultsHash
    }
}
