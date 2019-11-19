//
//  ButtonInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class ButtonInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    let iconName: String?
    let isEnabled: Bool
    
    var type: EntityInfoFieldType {
        return .button
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, title: String?, iconName: String?, isEnabled: Bool) {
        self.fieldId = fieldId
        self.title = title
        self.iconName = iconName
        self.isEnabled = isEnabled
    }
}
