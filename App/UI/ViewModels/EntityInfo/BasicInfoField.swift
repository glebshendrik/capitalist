//
//  BasicInfoField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class BasicInfoField : EntityInfoField {
    private let fieldId: String
    let title: String?
    let value: String?
    let valueColorAsset: ColorAsset
    
    var type: EntityInfoFieldType {
        return .basic
    }
    
    var identifier: String {
        return fieldId
    }
    
    init(fieldId: String, title: String?, value: String?, valueColorAsset: ColorAsset = .white100) {
        self.fieldId = fieldId
        self.title = title
        self.value = value
        self.valueColorAsset = valueColorAsset
    }
}
