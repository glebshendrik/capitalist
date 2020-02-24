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
        
    let id: Int?
    var reminderStartDate: Date? = nil
    var reminderRecurrenceRule: String? = nil
    var reminderMessage: String? = nil
    
    var reminderAttributes: ReminderNestedAttributes? {
        return ReminderNestedAttributes(id: id,
                                        startDate: reminderStartDate,
                                        recurrenceRule: reminderRecurrenceRule,
                                        message: reminderMessage)
    }
    
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
    
    var nextOccurrence: String? {
        guard let reminderStartDate = reminderStartDate else { return nil }
        guard let recurrenceRule = recurrenceRule else {
            return reminderStartDate.isInFuture ? startDate : nil
        }
        let nextOccurrence = recurrenceRule.occurrences(between: Date(), and: Date().adding(.year, value: 2)).first
        return nextOccurrence?.dateTimeString(ofStyle: DateFormatter.Style.medium)         
    }
    
    var reminder: String? {
        guard let reminderStartDate = reminderStartDate else { return nil }
        guard let recurrenceRule = recurrenceRule else {
            if reminderStartDate.isInFuture,
                let startDate = startDate {
                                
                return String(format: NSLocalizedString("Следующее напоминание: %@.", comment: "Следующее напоминание: %@."), startDate)
            }
            return nil
        }
        var reminderString = ""
        if let nextOccurrence = recurrenceRule.occurrences(between: Date(), and: Date().adding(.year, value: 2)).first {
            let nextOccurrenceString = nextOccurrence.dateTimeString(ofStyle: DateFormatter.Style.medium)
            
            reminderString.append(String(format: NSLocalizedString("Следующее напоминание: %@. ", comment: "Следующее напоминание: %@. "), nextOccurrenceString))
        }
        if let recurrenceRuleText = recurrenceRuleText {            
            reminderString.append(String(format: NSLocalizedString("Повторение: %@", comment: "Повторение: %@"), recurrenceRuleText.lowercased()))
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
        id = nil
    }
     
    init(reminder: Reminder?) {
        self.id = reminder?.id
        self.reminderStartDate = reminder?.startDate
        self.reminderRecurrenceRule = reminder?.recurrenceRule
        self.reminderMessage = reminder?.message
    }
        
    mutating func prepareForSaving() {
        if  let reminderStartDate = reminderStartDate,
            var recurrenceRule = recurrenceRule {
            recurrenceRule.startDate = reminderStartDate
            reminderRecurrenceRule = recurrenceRule.toRRuleString()
        }
    }
    
    mutating func clear() {
        reminderStartDate = nil
        reminderRecurrenceRule = nil
        reminderMessage = nil
    }
}
