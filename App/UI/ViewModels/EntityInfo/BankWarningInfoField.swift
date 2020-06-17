//
//  BankWarningInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class BankWarningInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    let message: String?
    let buttonText: String?
    
    var type: EntityInfoFieldType {
        return .bankWarning
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, title: String?, message: String?, buttonText: String?) {
        self.fieldId = fieldId
        self.title = title
        self.message = message
        self.buttonText = buttonText
    }
}
