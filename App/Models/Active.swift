//
//  Active.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//
import Foundation

enum ActiveIncomeType : String, Codable {
    case annualPercents = "annual_percents"
    case monthlyIncome = "monthly_income"
    
    var title: String {
        switch self {
        case .annualPercents:
            return NSLocalizedString("Процент годовых", comment: "Процент годовых")
        case .monthlyIncome:
            return NSLocalizedString("Доход в месяц", comment: "Доход в месяц")
        }
    }
}

struct Active : Decodable {
    let id: Int
    let basketId: Int
    let basketType: BasketType
    let activeType: ActiveType
    let name: String
    let iconURL: URL?
    let currency: Currency
    let costCents: Int
    let alreadyPaidCents: Int?
    let monthlyPaymentCents: Int?
    let paymentCentsAtPeriod: Int?
    let investedCents: Int
    let boughtCents: Int
    let spentCents: Int
    let annualIncomePercent: Int?
    let monthlyPlannedIncomeCents: Int?
    let goalAmountCents: Int?
    let plannedIncomeType: ActiveIncomeType?
    let isIncomePlanned: Bool
    let rowOrder: Int
    let deletedAt: Date?
    let reminder: Reminder?
    let incomeSource: IncomeSource?
    let prototypeKey: String?
    
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
        case paymentCentsAtPeriod = "payment_cents_at_period"
        case investedCents = "invested_at_period_cents"
        case boughtCents = "bought_at_period_cents"
        case spentCents = "spent_at_period_cents"
        case annualIncomePercent = "annual_income_percent"
        case monthlyPlannedIncomeCents = "monthly_planned_income_cents"
        case goalAmountCents = "goal_amount_cents"
        case plannedIncomeType = "planned_income_type"
        case isIncomePlanned = "is_income_planned"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
        case reminder
        case alreadyPaidCents = "already_paid_cents"
        case incomeSource = "income_source"
        case prototypeKey = "prototype_key"
    }
}

struct ActiveCreationForm : Encodable, Validatable {
    var basketId: Int?
    let activeTypeId: Int?
    let name: String?
    let iconURL: URL?
    let currency: String?
    let costCents: Int?
    let monthlyPaymentCents: Int?
    let annualIncomePercent: Int?
    let monthlyPlannedIncomeCents: Int?
    let goalAmountCents: Int?
    let alreadyPaidCents: Int?
    let plannedIncomeType: ActiveIncomeType?
    let isIncomePlanned: Bool
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case activeTypeId = "active_type_id"
        case name
        case iconURL = "icon_url"
        case currency
        case costCents = "cost_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case annualIncomePercent = "annual_income_percent"
        case monthlyPlannedIncomeCents = "monthly_planned_income_cents"
        case goalAmountCents = "goal_amount_cents"
        case alreadyPaidCents = "already_paid_cents"
        case plannedIncomeType = "planned_income_type"
        case isIncomePlanned = "is_income_planned"
        case reminderAttributes = "reminder_attributes"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: basketId) {
            errors["basket_id"] = "Ошибка сохранения"
        }
        
        if !Validator.isValid(present: activeTypeId) {
            errors["active_type"] = "Укажите тип актива"
        }
        
        if !Validator.isValid(required: name) {
            errors[CodingKeys.name.rawValue] = "Укажите название"
        }
        
        if  !Validator.isValid(required: currency) {
            errors[CodingKeys.currency.rawValue] = "Укажите валюту"
        }
        
        if !Validator.isValid(balance: costCents) {
            errors[CodingKeys.costCents.rawValue] = "Укажите стоимость"
        }
        
        if !Validator.isValid(optionalPositiveNumber: monthlyPlannedIncomeCents) {
            errors[CodingKeys.monthlyPlannedIncomeCents.rawValue] = "Укажите сумму больше 0"
        }
        
        if !Validator.isValid(optionalPositiveNumber: annualIncomePercent) {
            errors[CodingKeys.annualIncomePercent.rawValue] = "Укажите процент больше 0"
        }
                                
        return errors
    }
}

struct ActiveUpdatingForm : Encodable, Validatable {
    var id: Int?
    let name: String?
    let iconURL: URL?
    let costCents: Int?
    let monthlyPaymentCents: Int?
    let annualIncomePercent: Int?
    let monthlyPlannedIncomeCents: Int?
    let goalAmountCents: Int?
    let plannedIncomeType: ActiveIncomeType?
    let isIncomePlanned: Bool
    let reminderAttributes: ReminderNestedAttributes?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case costCents = "cost_cents"
        case monthlyPaymentCents = "monthly_payment_cents"
        case annualIncomePercent = "annual_income_percent"
        case monthlyPlannedIncomeCents = "monthly_planned_income_cents"
        case goalAmountCents = "goal_amount_cents"
        case plannedIncomeType = "planned_income_type"
        case isIncomePlanned = "is_income_planned"
        case reminderAttributes = "reminder_attributes"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
                
        try container.encode(name, forKey: .name)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(costCents, forKey: .costCents)
        try container.encode(monthlyPaymentCents, forKey: .monthlyPaymentCents)
        try container.encode(annualIncomePercent, forKey: .annualIncomePercent)
        try container.encode(monthlyPlannedIncomeCents, forKey: .monthlyPlannedIncomeCents)
        try container.encode(goalAmountCents, forKey: .goalAmountCents)
        try container.encode(plannedIncomeType, forKey: .plannedIncomeType)
        try container.encode(isIncomePlanned, forKey: .isIncomePlanned)
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
                
        if !Validator.isValid(balance: costCents) {
            errors[CodingKeys.costCents.rawValue] = NSLocalizedString("Укажите стоимость", comment: "Укажите стоимость")
        }
          
        if !Validator.isValid(optionalPositiveNumber: monthlyPlannedIncomeCents) {
            errors[CodingKeys.monthlyPlannedIncomeCents.rawValue] = NSLocalizedString("Укажите сумму больше 0", comment: "Укажите сумму больше 0")
        }
        
        if !Validator.isValid(optionalPositiveNumber: annualIncomePercent) {
            errors[CodingKeys.annualIncomePercent.rawValue] = NSLocalizedString("Укажите процент больше 0", comment: "Укажите процент больше 0")
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
