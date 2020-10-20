//
//  SwitchInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class SwitchInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    var value: Bool
    
    var type: EntityInfoFieldType {
        return .bool
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, title: String?, value: Bool) {
        self.fieldId = fieldId
        self.title = title
        self.value = value
    }
}
