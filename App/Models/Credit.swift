//
//  Credit.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 24/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Credit : Decodable {
    let id: Int
    let userId: Int
    let creditType: CreditType
    let name: String
    let iconURL: URL?
    let currency: Currency
    let amountCents: Int?
    let returnAmountCents: Int
    let paidAmountCents: Int
    let amountLeftCents: Int
    let monthlyPaymentCents: Int?
    let gotAt: Date
    let period: Int
    let isPaid: Bool
    let deletedAt: Date?
    let expenseCategoryId: Int
    let reminder: Reminder?
    let expenseCategory: ExpenseCategory?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case creditType = "credit_type"
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case returnAmountCents = "return_amount_cents"
        case paidAmountCents = "paid_amount_cents"
        case amountLeftCents = "amount_left_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case period
        case isPaid = "is_paid"
        case deletedAt = "deleted_at"
        case expenseCategoryId = "expense_category_id"
        case reminder
        case expenseCategory = "expense_category"
    }
}

struct CreditCreationForm : Encodable, Validatable {
    var userId: Int?
    let creditTypeId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let amountCents: Int?
    let returnAmountCents: Int?
    let alreadyPaidCents: Int?
    let monthlyPaymentCents: Int?
    let gotAt: Date
    let period: Int?
    let reminderAttributes: ReminderNestedAttributes?
    let creditingTransactionAttributes: CreditingTransactionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case creditTypeId = "credit_type_id"
        case name
        case iconURL = "icon_url"
        case currency
        case amountCents = "amount_cents"
        case returnAmountCents = "return_amount_cents"
        case alreadyPaidCents = "already_paid_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case period
        case reminderAttributes = "reminder_attributes"
        case creditingTransactionAttributes = "crediting_transaction_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(present: creditTypeId) {
            errors[CodingKeys.creditTypeId.rawValue] = NSLocalizedString("Укажите тип кредита", comment: "Укажите тип кредита")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(positiveMoney: returnAmountCents) {
            errors["return_amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(money: alreadyPaidCents) {
            errors[CodingKeys.alreadyPaidCents.rawValue] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors[CodingKeys.gotAt.rawValue] = NSLocalizedString("Укажите дату", comment: "Укажите дату")
        }
        
        if !Validator.isValid(present: period) {
            errors[CodingKeys.period.rawValue] = NSLocalizedString("Укажите период", comment: "Укажите период")
        }
        
        return errors
    }
}

struct CreditingTransactionNestedAttributes : Encodable {
    let id: Int?
    let destinationId: Int?
    let destinationType: TransactionableType = .expenseSource
    
    enum CodingKeys: String, CodingKey {
        case id
        case destinationId = "destination_id"
        case destinationType = "destination_type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        if let destinationId = destinationId {
            try container.encode(destinationId, forKey: .destinationId)
        }        
        try container.encode(destinationType, forKey: .destinationType)
    }
}

struct CreditUpdatingForm : Encodable, Validatable {
    var id: Int?
    let name: String?
    let iconURL: URL?
    let amountCents: Int?
    let returnAmountCents: Int?
    let monthlyPaymentCents: Int?
    let gotAt: Date?
    let period: Int?
    let reminderAttributes: ReminderNestedAttributes?
    let creditingTransactionAttributes: CreditingTransactionNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
        case returnAmountCents = "return_amount_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case gotAt = "got_at"
        case period
        case reminderAttributes = "reminder_attributes"
        case creditingTransactionAttributes = "crediting_transaction_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
                
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
        
        if !Validator.isValid(positiveMoney: returnAmountCents) {
            errors["return_amount"] = NSLocalizedString("Укажите сумму", comment: "Укажите сумму")
        }
                
        if !Validator.isValid(pastDate: gotAt) {
            errors[CodingKeys.gotAt.rawValue] = NSLocalizedString("Укажите дату", comment: "Укажите дату")
        }
        
        if !Validator.isValid(present: period) {
            errors[CodingKeys.period.rawValue] = NSLocalizedString("Укажите период", comment: "Укажите период")
        }
        
        return errors
    }
}
