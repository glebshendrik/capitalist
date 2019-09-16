//
//  ExpenseSource.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

protocol Validatable {
    func validate() -> [String : String]?
}

enum AccountType : String, Codable {
    case usual
    case goal
    case debt
    
    var iconCategory: IconCategory {
        switch self {
        case .usual:
            return .expenseSource
        case .goal:
            return .expenseSourceGoal
        case .debt:
            return .expenseSourceDebt
        }
    }
}

struct ExpenseSource : Decodable {
    let id: Int
    let name: String
    let amountCurrency: String
    let amount: String
    var amountCents: Int
    let currency: Currency
    let iconURL: URL?
    let accountType: AccountType
    let goalAmountCents: Int?
    var creditLimitCents: Int?
    let order: Int
    let deletedAt: Date?
    let waitingDebts: [Borrow]?
    let waitingLoans: [Borrow]?
    let accountConnection: AccountConnection?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amountCurrency = "amount_currency"
        case amount
        case amountCents = "amount_cents"
        case iconURL = "icon_url"
        case accountType = "account_type"
        case goalAmountCents = "goal_amount_cents"
        case order = "row_order"
        case currency = "currency"
        case deletedAt = "deleted_at"
        case waitingDebts = "waiting_debts"
        case waitingLoans = "waiting_loans"
        case creditLimitCents = "credit_limit_cents"
        case accountConnection = "account_connection"
    }
    
}

struct ExpenseSourceCreationForm : Encodable, Validatable {
    var userId: Int?
    let name: String?
    let iconURL: URL?
    let amountCurrency: String?
    let amountCents: Int?
    let accountType: AccountType
    let goalAmountCents: Int?
    let goalAmountCurrency: String?
    let creditLimitCents: Int?
    let creditLimitCurrency: String?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCurrency = "amount_currency"
        case amountCents = "amount_cents"
        case accountType = "account_type"
        case goalAmountCents = "goal_amount_cents"
        case goalAmountCurrency = "goal_amount_currency"
        case creditLimitCents = "credit_limit_cents"
        case creditLimitCurrency = "credit_limit_currency"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: amountCurrency) &&
            !Validator.isValid(required: goalAmountCurrency) &&
            !Validator.isValid(required: creditLimitCurrency) {
            
            errors[CodingKeys.amountCurrency.rawValue] = "Укажите валюту"
        }
        
        if !Validator.isValid(balance: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите текущий баланс"
        }
        
        if accountType == .goal && !Validator.isValid(money: goalAmountCents) {
            errors[CodingKeys.goalAmountCents.rawValue] = "Укажите сумму цели"
        }
        
        if accountType == .usual && !Validator.isValid(money: creditLimitCents) {
            errors[CodingKeys.creditLimitCents.rawValue] = "Укажите кредитный лимит (0 для обычного кошелька)"
        }
        
        return errors
    }
}

struct ExpenseSourceUpdatingForm : Encodable, Validatable {
    let id: Int?
    let accountType: AccountType
    let name: String?
    let amountCents: Int?
    let iconURL: URL?
    let goalAmountCents: Int?
    let creditLimitCents: Int?
    let accountConnectionAttributes: AccountConnectionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case goalAmountCents = "goal_amount_cents"
        case creditLimitCents = "credit_limit_cents"
        case accountConnectionAttributes = "account_connection_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if !Validator.isValid(balance: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите текущий баланс"
        }
        
        if accountType == .goal && !Validator.isValid(money: goalAmountCents) {
            errors[CodingKeys.goalAmountCents.rawValue] = "Укажите сумму цели"
        }
        
        if accountType == .usual && !Validator.isValid(money: creditLimitCents) {
            errors[CodingKeys.creditLimitCents.rawValue] = "Укажите кредитный лимит (0 для обычного кошелька)"
        }
        
        return errors
    }
}

struct ExpenseSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}

