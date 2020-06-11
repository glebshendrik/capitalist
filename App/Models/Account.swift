//
//  Account.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

enum AccountNatureType : String, Codable {
    case account
    case investment
    case undefined
}

enum AccountNature : String, Codable {
    case account
    case bonus
    case card
    case checking
    case credit
    case creditCard = "credit_card"
    case debitCard = "debit_card"
    case ewallet
    case insurance
    case investment
    case loan
    case mortgage
    case savings
}

struct Account : Decodable {
    let id: Int
    let accountId: String
    let accountName: String
    let accountFullName: String?
    let assetClass: Int?
    let balance: Int
    let cardType: CardType?
    let cardNumbers: [String]?
    let connection: Connection
    let currency: Currency
    let nature: AccountNature
    let creditLimit: Int?
    let fundHoldingActualPrice: Int?
    let fundHoldingActualValue: String?
    let fundHoldingAvailableQuality: String?
    let fundHoldingBalance: Int?
    let fundHoldingBidPrice: Int?
    let fundHoldingInvestmentPercentage: String?
    let fundHoldingTotalQuality: String?
    let fundHoldingValue: String?
    let fundHoldingValueDate: String?
    let interestAmount: Int?
    let interestIncome: Int?
    let productType: String?
    let profitAmount: Int?
    let profitRate: Int?
    let status: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case accountName = "account_name"
        case accountFullName = "account_full_name"
        case assetClass = "asset_class"
        case balance = "balance"
        case cardType = "card_type"
        case cardNumbers = "cards"
        case connection = "connection"
        case currency = "currency"
        case nature = "nature"
        case creditLimit = "credit_limit"
        case fundHoldingActualPrice = "fund_holding_actual_price"
        case fundHoldingActualValue = "fund_holding_actual_value"
        case fundHoldingAvailableQuality = "fund_holding_available_quality"
        case fundHoldingBalance = "fund_holding_balance"
        case fundHoldingBidPrice = "fund_holding_bid_price"
        case fundHoldingInvestmentPercentage = "fund_holding_investment_percentage"
        case fundHoldingTotalQuality = "fund_holding_total_quality"
        case fundHoldingValue = "fund_holding_value"
        case fundHoldingValueDate = "fund_holding_value_date"
        case interestAmount = "interest_amount"
        case interestIncome = "interest_income"
        case productType = "product_type"
        case profitAmount = "profit_amount"
        case profitRate = "profit_rate"
        case status = "status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
