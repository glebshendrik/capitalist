//
//  IconInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class IconInfoField : EntityInfoField {
    enum IconType {
        case raster
        case vector
    }
    
    private let fieldId: String
    let iconType: IconType
    let iconURL: URL?
    let placeholder: String?
    
    var type: EntityInfoFieldType {
        return .icon
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, iconType: IconType, iconURL: URL?, placeholder: String?) {
        self.fieldId = fieldId
        self.iconType = iconType
        self.iconURL = iconURL
        self.placeholder = placeholder
    }
}
