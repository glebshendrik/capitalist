//
//  HeaderInfoField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class CombinedInfoField : EntityInfoField {
    private let fieldId: String
    
    var type: EntityInfoFieldType {
        return .header
    }
    
    var identifier: String {
        return fieldId
    }
    
    var iconInfoField: IconInfoField?
    var mainInfoField: BasicInfoField?
    var firstInfoField: BasicInfoField?
    var secondInfoField: BasicInfoField?
    var thirdInfoField: BasicInfoField?
    
    var isIconFieldHidden: Bool {
        return iconInfoField == nil
    }
    
    var isMainFieldHidden: Bool {
        return mainInfoField == nil
    }
    
    var isFirstFieldHidden: Bool {
        return firstInfoField == nil
    }
    
    var isSecondFieldHidden: Bool {
        return secondInfoField == nil
    }
    
    var isThirdFieldHidden: Bool {
        return thirdInfoField == nil
    }

    var areBasicFieldsHidden: Bool {
        return isMainFieldHidden && areBasicSubFieldsHidden
    }
    
    var areBasicSubFieldsHidden: Bool {
        return isFirstFieldHidden && isSecondFieldHidden && isThirdFieldHidden
    }
    
    init(fieldId: String, icon: IconInfoField?, main: BasicInfoField?, first: BasicInfoField?, second: BasicInfoField?, third: BasicInfoField?) {
        self.fieldId = fieldId
        self.iconInfoField = icon
        self.mainInfoField = main
        self.firstInfoField = first
        self.secondInfoField = second
        self.thirdInfoField = third
    }
}



