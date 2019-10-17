//
//  ExpenseCategory.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct ExpenseCategory : Decodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let basketId: Int
    let basketType: BasketType
    let monthlyPlannedCurrency: String?
    let monthlyPlannedCents: Int?
    let spentCentsAtPeriod: Int
    let spentCurrency: String
    let plannedCentsAtPeriod: Int?
    let currency: Currency
    let incomeSourceDependentCurrency: Currency
    let incomeSourceCurrency: String
    let order: Int
    let deletedAt: Date?
    let reminder: Reminder?
    let creditId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case basketType = "basket_type"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
        case spentCentsAtPeriod = "spent_cents_at_period"
        case spentCurrency = "spent_currency"
        case plannedCentsAtPeriod = "planned_cents_at_period"
        case order = "row_order"
        case currency = "currency"
        case incomeSourceDependentCurrency = "income_source_dependent_currency"
        case incomeSourceCurrency = "income_source_currency"
        case deletedAt = "deleted_at"
        case reminder
        case creditId = "credit_id"
    }
    
}

struct ExpenseCategoryCreationForm : Encodable, Validatable {
    let basketId: Int?
    let iconURL: URL?
    let name: String?
    let monthlyPlannedCents: Int?
    let monthlyPlannedCurrency: String?
    let incomeSourceCurrency: String?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
        case incomeSourceCurrency = "income_source_currency"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: basketId) {
            errors["basket_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: monthlyPlannedCurrency) {
            errors[CodingKeys.monthlyPlannedCurrency.rawValue] = "Укажите валюту"
        }
        
        if  !Validator.isValid(required: incomeSourceCurrency) {
            errors[CodingKeys.incomeSourceCurrency.rawValue] = "Укажите валюту"
        }
        
        return errors
    }
}

struct ExpenseCategoryUpdatingForm : Encodable, Validatable {
    let id: Int?
    let iconURL: URL?
    let name: String?    
    let monthlyPlannedCents: Int?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case monthlyPlannedCents = "monthly_planned_cents"
        case reminderAttributes = "reminder_attributes"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)        
        try container.encode(monthlyPlannedCents, forKey: .monthlyPlannedCents)
        try container.encode(reminderAttributes, forKey: .reminderAttributes)
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
                        
        return errors
    }
}

struct ExpenseCategoryPositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
