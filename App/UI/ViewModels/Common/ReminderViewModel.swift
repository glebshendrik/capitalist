//
//  ReminderViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import RecurrencePicker

struct ReminderViewModel {
        
    var reminderStartDate: Date? = nil
    var reminderRecurrenceRule: String? = nil
    var reminderMessage: String? = nil
    
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
        guard let reminderStartDate = reminderStartDate else { return nil }
        guard let recurrenceRule = recurrenceRule else {
            if reminderStartDate.isInFuture,
                let startDate = startDate {
                return "Следующее напоминание: \(startDate)."
            }
            return nil
        }
        var reminderString = ""
        if let nextOccurrence = recurrenceRule.occurrences(between: Date(), and: Date().adding(.year, value: 2)).first {
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
    
    var removeButtonHidden: Bool {
        return !isReminderSet
    }
    
    init() {
        
    }
     
    init(reminderStartDate: Date?, reminderRecurrenceRule: String?, reminderMessage: String?) {
        self.reminderStartDate = reminderStartDate
        self.reminderRecurrenceRule = reminderRecurrenceRule
        self.reminderMessage = reminderMessage
    }
    
    init(incomeSource: IncomeSource) {
        self.init(reminderStartDate: incomeSource.reminderStartDate,
                  reminderRecurrenceRule: incomeSource.reminderRecurrenceRule,
                  reminderMessage: incomeSource.reminderMessage)
    }
    
    init(expenseCategory: ExpenseCategory) {
        self.init(reminderStartDate: expenseCategory.reminderStartDate,
                  reminderRecurrenceRule: expenseCategory.reminderRecurrenceRule,
                  reminderMessage: expenseCategory.reminderMessage)
    }
    
    mutating func prepareForSaving() {
        if  let reminderStartDate = reminderStartDate,
            var recurrenceRule = recurrenceRule {
            recurrenceRule.startDate = reminderStartDate
            reminderRecurrenceRule = recurrenceRule.toRRuleString()
        }
    }
    
    mutating func clear() {
        reminderMessage = nil
        reminderStartDate = nil
        reminderRecurrenceRule = nil
    }
}
