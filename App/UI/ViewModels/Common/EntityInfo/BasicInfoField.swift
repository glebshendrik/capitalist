//
//  BasicInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class BasicInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    let value: String?
    
    var type: EntityInfoFieldType {
        return .basic
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, title: String?, value: String?) {
        self.fieldId = fieldId
        self.title = title
        self.value = value
    }
}
