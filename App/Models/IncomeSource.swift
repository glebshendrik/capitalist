//
//  IncomeSource.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation

struct IncomeSource : Decodable {
    let id: Int
    let name: String
    let currency: Currency
    let gotCentsAtPeriod: Int
    let iconURL: URL?
    let order: Int
    let deletedAt: Date?
    let isChild: Bool
    let activeId: Int?
    let monthlyPlannedCents: Int?
    let plannedCentsAtPeriod: Int?
    let isBorrowOrReturn: Bool
    let waitingDebts: [Borrow]
    let reminder: Reminder?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
        case gotCentsAtPeriod = "got_cents_at_period"
        case iconURL = "icon_url"
        case order = "row_order"
        case deletedAt = "deleted_at"
        case isChild = "is_child"
        case activeId = "active_id"
        case monthlyPlannedCents = "monthly_planned_cents"
        case plannedCentsAtPeriod = "planned_cents_at_period"
        case isBorrowOrReturn = "is_borrow_or_return"
        case waitingDebts = "waiting_debts"
        case reminder
    }

}

struct IncomeSourceCreationForm : Encodable, Validatable {
    let userId: Int?
    let iconURL: URL?
    let name: String?
    let currency: String?
    let monthlyPlannedCents: Int?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
        case name
        case currency
        case monthlyPlannedCents = "monthly_planned_cents"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
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

struct IncomeSourceUpdatingForm : Encodable, Validatable {
    let id: Int?
    let iconURL: URL?
    let name: String?
    let monthlyPlannedCents: Int?
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
        case name
        case monthlyPlannedCents = "monthly_planned_cents"
        case reminderAttributes = "reminder_attributes"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(name, forKey: .name)
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

struct IncomeSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
