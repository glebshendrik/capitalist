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
            return "Процент годовых"
        case .monthlyIncome:
            return "Доход в месяц"
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
    let monthlyPaymentCents: Int?
    let investedCents: Int
    let boughtCents: Int
    let spentCents: Int
    let annualIncomePercent: Int?
    let monthlyPlannedIncomeCents: Int?
    let plannedIncomeType: ActiveIncomeType?
    let isIncomePlanned: Bool
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
        case monthlyPlannedIncomeCents = "monthly_planned_income_cents"
        case plannedIncomeType = "planned_income_type"
        case isIncomePlanned = "is_income_planned"
        case rowOrder = "row_order"
        case deletedAt = "deleted_at"
        case reminder
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
        case plannedIncomeType = "planned_income_type"
        case isIncomePlanned = "is_income_planned"
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
