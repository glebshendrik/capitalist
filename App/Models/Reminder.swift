//
//  Reminder.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

struct Reminder : Decodable {
    let id: Int
    let startDate: Date?
    let recurrenceRule: String?
    let message: String?
            
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case recurrenceRule = "recurrence_rule"
        case message
    }
}

struct ReminderNestedAttributes : Encodable {
    let id: Int?
    let startDate: Date?
    let recurrenceRule: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case recurrenceRule = "recurrence_rule"
        case message
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(startDate, forKey: .startDate)
        try container.encode(recurrenceRule, forKey: .recurrenceRule)
        try container.encode(message, forKey: .message)
    }
}
