//
//  EntityInfoFieldsSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class EntityInfoFieldsSection : EntityInfoSection {
    private let infoFields: [EntityInfoField]
    
    var isSectionHeaderVisible: Bool { return false }
    var numberOfRows: Int { return infoFields.count }
    var title: String? { return nil }
    var type: EntityInfoSectionType { return .entityInfoFields }
    
    init(infoFields: [EntityInfoField]) {
        self.infoFields = infoFields
    }
    
    func infoField(at index: Int) -> EntityInfoField? {
        return infoFields.item(at: index)
    }
}
