//
//  ReminderInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class ReminderInfoField : EntityInfoField {
    private let fieldId: String
    private let reminder: ReminderViewModel?
    
    var type: EntityInfoFieldType {
        return .reminder
    }
    
    var identifier: String {
        return fieldId
    }
    
    var reminderButtonText: String? {
        guard let reminder = reminder, reminder.isReminderSet else { return NSLocalizedString("Установить напоминание", comment: "Установить напоминание") }
        return NSLocalizedString("Изменить напоминание", comment: "Изменить напоминание")
    }
    
    var nextOccurence: String? {
        if let nextOccurrence = reminder?.nextOccurrence {            
            return String(format: NSLocalizedString("Следующее: %@", comment: "Следующее: %@"), nextOccurrence)
        }
        return reminder?.startDate
    }
    
    var recurrence: String? {
        return reminder?.recurrenceRuleText
    }
    
    var reminderMessage: String? {
        return reminder?.reminderMessage
    }
    
    init(fieldId: String, reminder: ReminderViewModel?) {
        self.fieldId = fieldId
        self.reminder = reminder
    }
}
