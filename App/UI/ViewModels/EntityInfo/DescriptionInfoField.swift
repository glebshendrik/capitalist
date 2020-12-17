//
//  DescriptionInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class DescriptionInfoField : EntityInfoField {
    private let fieldId: String
    let description: String?
    
    var type: EntityInfoFieldType {
        return .description
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, description: String?) {
        self.fieldId = fieldId
        self.description = description
    }
}
