//
//  ExpenseSource.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct ExpenseSource : Decodable {
    let id: Int
    let name: String
    let amountCurrency: String
    let amount: String
    let iconURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amountCurrency = "amount_currency"
        case amount
        case iconURL = "icon_url"
    }
    
}

struct ExpenseSourceCreationForm : Encodable {
    let userId: Int
    let name: String
    let iconURL: URL?
    let amountCurrency: String = "RUB"
    let amountCents: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCurrency = "amount_currency"
        case amountCents = "amount_cents"
    }
}

struct ExpenseSourceUpdatingForm : Encodable {
    let id: Int
    let name: String
    let iconURL: URL?
    let amountCents: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconURL = "icon_url"
        case amountCents = "amount_cents"
    }
}