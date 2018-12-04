//
//  ValidationResult.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

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
    static func validate(email: String?, key: CodingKey) -> ValidationResult<String> {
        guard let email = email, !email.isEmpty else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        return .success(key: key,
                        value: email)
    }
    
    static func validate(password: String?, key: CodingKey) -> ValidationResult<String> {
        guard let password = password, !password.isEmpty else {
            return .failure(key: key,
                            reasons: [ValidationErrorReason.required])
        }
        return .success(key: key,
                        value: password)
    }
    
    static func validate(passwordConfirmation: String?,
                         password: String?,
                         passwordConfirmationKey: CodingKey,
                         passwordKey: CodingKey) -> ValidationResult<String> {
        
        guard let passwordConfirmation = passwordConfirmation, !passwordConfirmation.isEmpty else {
            return .failure(key: passwordConfirmationKey,
                            reasons: [ValidationErrorReason.required])
        }
        guard password == passwordConfirmation else {
            return .failure(key: passwordConfirmationKey,
                            reasons: [ValidationErrorReason.notEqual(to: passwordKey)])
        }
        return .success(key: passwordConfirmationKey,
                        value: passwordConfirmation)
    }
}
