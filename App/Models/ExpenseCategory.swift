//
//  ExpenseCategory.swift
//  Capitalist
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
    let monthlyPlannedCents: Int?
    let spentCentsAtPeriod: Int
    let plannedCentsAtPeriod: Int?
    let currency: Currency
    let order: Int
    let deletedAt: Date?
    let reminder: Reminder?
    let creditId: Int?
    let isBorrowOrReturn: Bool    
    let waitingLoans: [Borrow]
    let prototypeKey: String?
    let isVirtual: Bool
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case basketType = "basket_type"
        case monthlyPlannedCents = "monthly_planned_cents"
        case spentCentsAtPeriod = "spent_cents_at_period"
        case plannedCentsAtPeriod = "planned_cents_at_period"
        case order = "row_order"
        case currency = "currency"
        case deletedAt = "deleted_at"
        case reminder
        case creditId = "credit_id"
        case isBorrowOrReturn = "is_borrow_or_return"        
        case waitingLoans = "waiting_loans"
        case prototypeKey = "prototype_key"
        case isVirtual = "is_virtual"
        case description
    }
    
}

struct ExpenseCategoryCreationForm : Encodable, Validatable {
    let basketId: Int?
    let iconURL: URL?
    let name: String?
    let currency: String?
    let monthlyPlannedCents: Int?
    let description: String?
    let prototypeKey: String?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case currency = "currency"
        case monthlyPlannedCents = "monthly_planned_cents"
        case description
        case prototypeKey = "prototype_key"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: basketId) {
            errors["basket_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
                
        return errors
    }
}

struct ExpenseCategoryUpdatingForm : Encodable, Validatable {
    let id: Int?
    let iconURL: URL?
    let name: String?    
    let monthlyPlannedCents: Int?
    let description: String?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case monthlyPlannedCents = "monthly_planned_cents"
        case description
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
            errors["id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = NSLocalizedString("Укажите название", comment: "Укажите название")
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
