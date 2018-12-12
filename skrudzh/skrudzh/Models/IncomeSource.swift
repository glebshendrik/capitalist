//
//  IncomeSource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct IncomeSource : Decodable {
    let id: Int
    let name: String
    let currency: String
    let iconURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
        case iconURL = "icon_url"
    }

}

struct IncomeSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let currency: String
    let iconURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name
        case currency
        case iconURL = "icon_url"
    }
}
