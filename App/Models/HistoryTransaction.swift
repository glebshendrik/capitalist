//
//  HistoryTransaction.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum TransactionableType : String, Codable {
    case income = "Income"
    case expense = "Expense"
    case fundsMove = "FundsMove"
}

enum HistoryTransactionSourceOrDestinationType : String, Codable {
    case incomeSource = "IncomeSource"
    case expenseSource = "ExpenseSource"
    case expenseCategory = "ExpenseCategory"
}

struct HistoryTransaction : Decodable {
    let id: Int
    let userId: Int
    let transactionableType: TransactionableType
    let transactionableId: Int
    let sourceId: Int
    let sourceType: HistoryTransactionSourceOrDestinationType
    let destinationId: Int
    let destinationType: HistoryTransactionSourceOrDestinationType
    let sourceTitle: String
    let destinationTitle: String
    let destinationIconURL: URL?
    let currency: Currency
    let amountCents: Int
    let convertedCurrency: Currency
    let convertedAmountCents: Int
    let gotAt: Date
    let comment: String?
    let basketType: BasketType?
    let whom: String?
    let borrowedTill: Date?
    let isReturned: Bool?
    let isReturn: Bool?
    let isDebt: Bool?
    let isLoan: Bool?
    let includedInBalance: Bool?
    let borrowId: Int?
    let borrowType: BorrowType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case transactionableType = "transactionable_type"
        case transactionableId = "transactionable_id"
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case sourceTitle = "source_title"
        case destinationTitle = "destination_title"
        case destinationIconURL = "destination_icon_url"
        case currency = "currency_object"
        case amountCents = "amount_cents"
        case convertedCurrency = "converted_currency_object"
        case convertedAmountCents = "converted_amount_cents"
        case gotAt = "got_at"
        case comment
        case basketType = "basket_type"
        case borrowedTill = "borrowed_till"
        case whom
        case isReturned = "is_returned"
        case isReturn = "is_return"
        case isDebt = "is_debt"
        case isLoan = "is_loan"
        case includedInBalance = "included_in_balance"
        case borrowId = "borrow_id"
        case borrowType = "borrow_type"
    }
    
}
