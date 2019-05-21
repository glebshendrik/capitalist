//
//  ExpenseCategory.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
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
    let includedInBalanceExpensesCents: Int?
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
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
        case includedInBalanceExpensesCents = "included_in_balance_expenses_cents"
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
    
}

struct ExpenseCategoryCreationForm : Encodable {
    let name: String
    let iconURL: URL?
    let basketId: Int
    let monthlyPlannedCurrency: String
    let monthlyPlannedCents: Int?
    let incomeSourceCurrency: String
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case basketId = "basket_id"
        case monthlyPlannedCurrency = "monthly_planned_currency"
        case monthlyPlannedCents = "monthly_planned_cents"
        case incomeSourceCurrency = "income_source_currency"
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
    
    init(name: String, iconURL: URL?, basketId: Int, monthlyPlannedCents: Int?, currency: String, incomeSourceCurrency: String, reminderStartDate: Date?, reminderRecurrenceRule: String?, reminderMessage: String?) {
        self.name = name
        self.iconURL = iconURL
        self.basketId = basketId
        self.monthlyPlannedCents = monthlyPlannedCents
        self.monthlyPlannedCurrency = currency
        self.incomeSourceCurrency = incomeSourceCurrency
        self.reminderStartDate = reminderStartDate
        self.reminderRecurrenceRule = reminderRecurrenceRule
        self.reminderMessage = reminderMessage
    }
}

struct ExpenseCategoryUpdatingForm : Encodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let monthlyPlannedCents: Int?
    let reminderStartDate: Date?
    let reminderRecurrenceRule: String?
    let reminderMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case monthlyPlannedCents = "monthly_planned_cents"
        case reminderStartDate = "reminder_start_date"
        case reminderRecurrenceRule = "reminder_recurrence_rule"
        case reminderMessage = "reminder_message"
    }
    
    init(id: Int, name: String, iconURL: URL?, monthlyPlannedCents: Int?, reminderStartDate: Date?, reminderRecurrenceRule: String?, reminderMessage: String?) {
        self.id = id
        self.name = name
        self.iconURL = iconURL
        self.monthlyPlannedCents = monthlyPlannedCents
        self.reminderStartDate = reminderStartDate
        self.reminderRecurrenceRule = reminderRecurrenceRule
        self.reminderMessage = reminderMessage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)        
        try container.encode(monthlyPlannedCents, forKey: .monthlyPlannedCents)
        try container.encode(reminderStartDate, forKey: .reminderStartDate)
        try container.encode(reminderRecurrenceRule, forKey: .reminderRecurrenceRule)
        try container.encode(reminderMessage, forKey: .reminderMessage)
    }
}

struct ExpenseCategoryPositionUpdatingForm : Encodable {
    let id: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case position = "row_order_position"
    }
}
