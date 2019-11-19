//
//  EntityInfoSection.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum EntityInfoSectionType {
    case entityInfoFields
    case transactionsLoader
    case transactionsHeader
    case transactions
}

protocol EntityInfoSection {
    var isSectionHeaderVisible: Bool { get }
    var numberOfRows: Int { get }
    var title: String? { get }
    var type: EntityInfoSectionType { get }
}
