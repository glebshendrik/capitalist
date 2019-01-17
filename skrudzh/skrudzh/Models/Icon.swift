//
//  Icon.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

enum IconCategory : String, Codable {
    case expenseSource = "expense_source"
    case expenseCategoryJoy = "expense_category_joy"
}

struct Icon : Decodable {
    let id: Int
    let url: URL
    let category: IconCategory
}