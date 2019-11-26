//
//  EntityInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum EntityInfoFieldType {
    case icon
    case basic
    case bool
    case button
    case reminder
    
    var identifier: String {
        switch self {
        case .icon:
            return "IconInfoTableViewCell"
        case .basic:
            return "BasicInfoTableViewCell"
        case .bool:
            return "SwitchInfoTableViewCell"
        case .button:
            return "ButtonInfoTableViewCell"
        case .reminder:
            return "ReminderInfoTableViewCell"
        }
    }
}

protocol EntityInfoField {
    var type: EntityInfoFieldType { get }
    var identifier: String { get }
}

extension EntityInfoField {
    var cellIdentifier: String { return type.identifier }
}
