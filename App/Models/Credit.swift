//
//  Credit.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 24/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum PeriodUnit : String, Codable {
    case days
    case months
    case years    
}

struct CreditType : Decodable {
    let id: Int
    let name: String
    let localizedKey: String
    let localizedName: String
    let periodUnit: PeriodUnit
    let minValue: Int
    let maxValue: Int
    let defaultValue: Int
    let hasMonthlyPayments: Bool
    let periodSuperUnit: PeriodUnit
    let unitsInSuperUnit: Int
    let rowOrder: Int
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedKey = "localized_key"
        case localizedName = "localized_name"
        case periodUnit = "period_unit"
        case minValue = "min_value"
        case maxValue = "max_value"
        case defaultValue = "default_value"
        case hasMonthlyPayments = "has_monthly_payments"
        case periodSuperUnit = "period_super_unit"
        case unitsInSuperUnit = "units_in_super_unit"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
    }
}

struct Credit : Decodable {
    let id: Int
    let userId: Int
    let creditType: CreditType
    let name: String
    let iconURL: URL?
    let currency: Currency
    let amountCents: Int
    let paidAmountCents: Int
    let amountLeftCents: Int
    let monthlyPaymentCents: Int?
    let gotAt: Date
    let isPaid: Bool
    let deletedAt: Date?
    let expenseCategoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case creditType = "credit_type"
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case paidAmountCents = "paid_amount_cents"
        case amountLeftCents = "amount_left_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case isPaid = "is_paid"
        case deletedAt = "deleted_at"
        case expenseCategoryId = "expense_category_id"
    }
}

struct ExpenseCategoryNestedAttributes : Encodable {
    let id: Int?
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        
        if let reminderStartDate = reminderStartDate {
            try container.encode(reminderStartDate, forKey: .reminderStartDate)
        }
        
        if let reminderRecurrenceRule = reminderRecurrenceRule {
            try container.encode(reminderRecurrenceRule, forKey: .reminderRecurrenceRule)
        }
        
        if let reminderMessage = reminderMessage {
            try container.encode(reminderMessage, forKey: .reminderMessage)
        }
    }
}

struct CreditCreationForm : Encodable, Validatable {
    var userId: Int?
    let creditTypeId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let amountCents: Int?
    let alreadyPaidCents: Int?
    let monthlyPaymentCents: Int?
    let gotAt: Date
    let period: Int?
    let expenseCategoryAttributes: ExpenseCategoryNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case creditTypeId = "credit_type_id"
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case alreadyPaidCents = "already_paid_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case period
        case expenseCategoryAttributes = "expense_category_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: creditTypeId) {
            errors[CodingKeys.creditTypeId.rawValue] = "Укажите тип кредита"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = "Укажите валюту"
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите сумму"
        }
        
        if !Validator.isValid(money: alreadyPaidCents) {
            errors[CodingKeys.alreadyPaidCents.rawValue] = "Укажите сумму"
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors[CodingKeys.gotAt.rawValue] = "Укажите дату"
        }
        
        if !Validator.isValid(present: period) {
            errors[CodingKeys.period.rawValue] = "Укажите период"
        }
        
        return errors
    }
}

struct CreditUpdatingForm : Encodable, Validatable {
    var id: Int?
    let name: String?
    let iconURL: URL?
    let amountCents: Int?
    let monthlyPaymentCents: Int?
    let gotAt: Date
    let period: Int?
    let expenseCategoryAttributes: ExpenseCategoryNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case period
        case expenseCategoryAttributes = "expense_category_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
                
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
                
        if !Validator.isValid(positiveMoney: amountCents) {
            errors[CodingKeys.amountCents.rawValue] = "Укажите сумму"
        }
                
        if !Validator.isValid(pastDate: gotAt) {
            errors[CodingKeys.gotAt.rawValue] = "Укажите дату"
        }
        
        if !Validator.isValid(present: period) {
            errors[CodingKeys.period.rawValue] = "Укажите период"
        }
        
        return errors
    }
}
