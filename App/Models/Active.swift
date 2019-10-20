//
//  Active.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//
import Foundation

struct Active : Decodable {
    let id: Int
    let basketId: Int
    let basketType: BasketType
    let activeType: ActiveType
    let name: String
    let iconURL: URL?
    let currency: Currency
    let costCents: Int
    let monthlyPaymentCents: Int?
    let investedCents: Int
    let boughtCents: Int
    let spentCents: Int
    let annualIncomePercent: Int?
    let rowOrder: Int
    let deletedAt: Date?
    let reminder: Reminder?
    
    enum CodingKeys: String, CodingKey {
        case id
        case basketId = "basket_id"
        case basketType = "basket_type"
        case activeType = "active_type"
        case name
        case iconURL = "icon_url"
        case currency
        case costCents = "cost_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case investedCents = "invested_at_period_cents"
        case boughtCents = "bought_at_period_cents"
        case spentCents = "spent_at_period_cents"
        case annualIncomePercent = "annual_income_percent"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
        case reminder
    }
}

struct ActiveCreationForm : Encodable, Validatable {
    var userId: Int?
    let activeType: ActiveType?
    let activeTypeId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let costCents: Int?
    let monthlyPaymentCents: Int?
    let annualIncomePercent: Int?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case activeTypeId = "active_type_id"
        case name
        case iconURL = "icon_url"
        case currency
        case costCents = "cost_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case annualIncomePercent = "annual_income_percent"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: activeTypeId) {
            errors[CodingKeys.activeTypeId.rawValue] = "Укажите тип актива"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = "Укажите валюту"
        }
        
        if !Validator.isValid(positiveMoney: costCents) {
            errors[CodingKeys.costCents.rawValue] = "Укажите стоимость"
        }
                        
        if let activeType = activeType, activeType.annualPercentRequired {
            if !Validator.isValid(present: annualIncomePercent) {
                errors[CodingKeys.annualIncomePercent.rawValue] = "Укажите процент годовых"
            }
        }
        
        return errors
    }
}

struct ActiveUpdatingForm : Encodable, Validatable {
    var id: Int?
    let activeType: ActiveType?
    let name: String?
    let iconURL: URL?
    let costCents: Int?
    let monthlyPaymentCents: Int?
    let annualIncomePercent: Int?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case costCents = "cost_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case annualIncomePercent = "annual_income_percent"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
                                
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
                
        if !Validator.isValid(balance: costCents) {
            errors[CodingKeys.costCents.rawValue] = "Укажите стоимость"
        }
                        
        if let activeType = activeType, activeType.annualPercentRequired {
            if !Validator.isValid(present: annualIncomePercent) {
                errors[CodingKeys.annualIncomePercent.rawValue] = "Укажите процент годовых"
            }
        }
        
        return errors
    }
}

struct ActivePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
