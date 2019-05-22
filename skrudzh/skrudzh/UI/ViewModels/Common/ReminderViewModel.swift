//
//  ReminderViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import RecurrencePicker

struct ReminderViewModel {
    
    var reminderMessage: String? = nil
    var reminderStartDate: Date? = nil
    var reminderRecurrenceRule: String? = nil
    
    var startDate: String? {        
        return reminderStartDate?.dateTimeString(ofStyle: DateFormatter.Style.medium)
    }
    
    var recurrenceRule: RecurrenceRule? {
        guard let rule = reminderRecurrenceRule else { return nil }
        return RecurrenceRule(rruleString: rule)
    }
    
    var recurrenceRuleText: String? {
        return recurrenceRule?.toText(occurrenceDate: reminderStartDate ?? Date())
    }
    
    var reminder: String? {
        guard isReminderSet else { return nil }
        var reminderString = ""
        if let nextOccurrence = recurrenceRule?.occurrences(between: Date(), and: Date().adding(.year, value: 2)).first {
            let nextOccurrenceString = nextOccurrence.dateTimeString(ofStyle: DateFormatter.Style.medium)
            reminderString.append("Следующее напоминание: \(nextOccurrenceString). ")
        }
        if let recurrenceRuleText = recurrenceRuleText {
            reminderString.append("Повторение: \(recurrenceRuleText.lowercased())")
        }
        return reminderString
    }
    
    var isReminderSet: Bool {
        return reminderStartDate != nil 
    }
    
    init() {
        
    }
    
    init(incomeSource: IncomeSource) {
        reminderMessage = incomeSource.reminderMessage
        reminderStartDate = incomeSource.reminderStartDate
        reminderRecurrenceRule = incomeSource.reminderRecurrenceRule
    }
    
    init(expenseCategory: ExpenseCategory) {
        reminderMessage = expenseCategory.reminderMessage
        reminderStartDate = expenseCategory.reminderStartDate
        reminderRecurrenceRule = expenseCategory.reminderRecurrenceRule
    }
    
    mutating func prepareForSaving() {
        if  let reminderStartDate = reminderStartDate,
            var recurrenceRule = recurrenceRule {
            recurrenceRule.startDate = reminderStartDate
            reminderRecurrenceRule = recurrenceRule.toRRuleString()
        }
    }
}
