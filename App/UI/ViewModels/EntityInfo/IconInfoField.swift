//
//  IconInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class IconInfoField : EntityInfoField {
    
    
    private let fieldId: String
    let iconType: IconType
    let iconURL: URL?
    let placeholder: String?
    let backgroundColor: UIColor
    let canEditIcon: Bool
    var type: EntityInfoFieldType {
        return .icon
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, iconType: IconType, iconURL: URL?, placeholder: String?, canEditIcon: Bool = true, backgroundColor: UIColor = .clear) {
        self.fieldId = fieldId
        self.iconType = iconType
        self.iconURL = iconURL
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.canEditIcon = canEditIcon
    }
}
