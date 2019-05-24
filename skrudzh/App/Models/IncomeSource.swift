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
    let isChild: Bool?
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
        case gotCentsAtPeriod = "got_cents_at_period"
        case iconURL = "icon_url"
        case order = "row_order"
        case deletedAt = "deleted_at"
        case isChild = "is_child"
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }

}

struct IncomeSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let currency: String
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case currency
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
}

struct IncomeSourceUpdatingForm : Encodable {
    let id: Int
    let name: String
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(reminderStartDate, forKey: .reminderStartDate)
        try container.encode(reminderRecurrenceRule, forKey: .reminderRecurrenceRule)
        try container.encode(reminderMessage, forKey: .reminderMessage)
    }
}

struct IncomeSourcePositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
