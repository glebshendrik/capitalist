//
//  Transaction.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

enum TransactionType : String, Codable {
    case income = "income"
    case expense = "expense"
    case fundsMove = "funds_move"
}

enum TransactionableType : String, Codable {
    case incomeSource = "IncomeSource"
    case expenseSource = "ExpenseSource"
    case expenseCategory = "ExpenseCategory"
    case active = "Active"
    
    var defaultIconName: String {
        switch (self) {
        case .incomeSource:                 return "income-source-default-icon"
        case .expenseSource:                return "expense-source-default-icon"
        case .expenseCategory:              return "expense-category-default-icon"
        case .active:                       return "asset-safe-default-icon"
        }
    }
    
    func defaultIconName(basketType: BasketType?) -> String {
        guard let basketType = basketType else { return defaultIconName }
        switch (self, basketType) {
        case (.active, .joy):               return "expense-category-default-icon"
        case (.active, .safe):              return "asset-safe-default-icon"
        case (.active, .risk):              return "asset-risk-default-icon"
        default:                            return defaultIconName
        }
    }
}

enum TransactionRemoteStatus : String, Codable {
    case pending = "pending"
    case posted = "posted"
}

struct Transaction : Decodable {
    let id: Int
    let userId: Int
    let type: TransactionType
    let sourceId: Int
    let sourceType: TransactionableType
    let destinationId: Int
    let destinationType: TransactionableType
    let sourceTitle: String
    let sourceIconURL: URL?
    let destinationTitle: String
    let destinationIconURL: URL?
    let currency: Currency
    let amountCents: Int
    let convertedCurrency: Currency
    let convertedAmountCents: Int
    let gotAt: Date
    let comment: String?
    let includedInBalance: Bool? = false
    let basketType: BasketType?
    let whom: String?
    let payday: Date?
    let isReturned: Bool?
    let borrow: Borrow?
    let returningBorrow: Borrow?
    let credit: Credit?
    let isBuyingAsset: Bool
    let isVirtualSource: Bool
    let isVirtualDestination: Bool
    let isBorrowOrReturnSource: Bool
    let isBorrowOrReturnDestination: Bool
    let isAssetSource: Bool
    let sourceActiveId: Int?
    let sourceActiveTitle: String?
    let sourceActiveIconURL: URL?
    let active: Active?
    let profitCents: Int?
    let sourceIncomeSourceId: Int?
    let accountId: Int?
    let saltedgeTransactionId: String?
    let saltedgeTransactionStatus: TransactionRemoteStatus?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type = "transaction_type"
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case sourceTitle = "source_title"
        case sourceIconURL = "source_icon_url"
        case destinationTitle = "destination_title"
        case destinationIconURL = "destination_icon_url"
        case currency = "amount_currency"
        case amountCents = "amount_cents"
        case convertedCurrency = "converted_amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case gotAt = "got_at"
        case comment
        case basketType = "basket_type"
        case payday
        case whom
        case isReturned = "is_returned"
        case borrow
        case returningBorrow = "returning_borrow"
        case credit
        case isBuyingAsset = "buying_asset"
        case isVirtualSource = "is_virtual_source"
        case isVirtualDestination = "is_virtual_destination"
        case isBorrowOrReturnSource = "is_borrow_or_return_source"
        case isBorrowOrReturnDestination = "is_borrow_or_return_destination"
        case isAssetSource = "is_active_source"
        case sourceActiveId = "source_active_id"
        case sourceActiveTitle = "source_active_title"
        case sourceActiveIconURL = "source_active_icon_url"
        case active = "active"
        case profitCents = "profit"
        case sourceIncomeSourceId = "source_income_source_id"
        case saltedgeTransactionId = "salt_edge_transaction_id"
        case accountId = "account_id"
        case saltedgeTransactionStatus = "salt_edge_transaction_status"
    }    
}

struct TransactionCreationForm : Encodable, Validatable {
    let userId: Int?
    let sourceId: Int?
    let sourceType: TransactionableType?
    let destinationId: Int?
    let destinationType: TransactionableType?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let returningBorrowId: Int?
    let isBuyingAsset: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case returningBorrowId = "returning_borrow_id"
        case isBuyingAsset = "buying_asset"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: userId) {
            errors["user_id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(present: sourceId) {
            errors["source_id"] = NSLocalizedString("Укажите источник", comment: "Укажите источник")
        }
        
        if !Validator.isValid(present: destinationId) {
            errors["destination_id"] = NSLocalizedString("Укажите назначение", comment: "Укажите назначение")
        }
        
        if !Validator.isValid(present: amountCurrency) {
            errors["amount_currency"] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
        
        if !Validator.isValid(present: convertedAmountCurrency) {
            errors["converted_amount_currency"] = NSLocalizedString("Укажите валюту конвертации", comment: "Укажите валюту конвертации")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму списания", comment: "Укажите сумму списания")
        }
        
        if !Validator.isValid(positiveMoney: convertedAmountCents) {
            errors["converted_amount"] = NSLocalizedString("Укажите сумму зачисления", comment: "Укажите сумму зачисления")
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors["got_at"] = NSLocalizedString("Укажите дату транзакции", comment: "Укажите дату транзакции")
        }
        
        return errors
    }
}

struct TransactionUpdatingForm : Encodable, Validatable {
    let id: Int?
    let sourceId: Int?
    let sourceType: TransactionableType?
    let destinationId: Int?
    let destinationType: TransactionableType?
    let amountCents: Int?
    let amountCurrency: String?
    let convertedAmountCents: Int?
    let convertedAmountCurrency: String?
    let gotAt: Date?
    let comment: String?
    let isBuyingAsset: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case sourceId = "source_id"
        case sourceType = "source_type"
        case destinationId = "destination_id"
        case destinationType = "destination_type"
        case amountCents = "amount_cents"
        case amountCurrency = "amount_currency"
        case convertedAmountCents = "converted_amount_cents"
        case convertedAmountCurrency = "converted_amount_currency"
        case gotAt = "got_at"
        case comment
        case isBuyingAsset = "buying_asset"
    }
    
    func validate() -> [String : String]? {
        var errors = [String : String]()
        
        if !Validator.isValid(present: id) {
            errors["id"] = NSLocalizedString("Ошибка сохранения", comment: "Ошибка сохранения")
        }
        
        if !Validator.isValid(present: sourceId) {
            errors["source_id"] = NSLocalizedString("Укажите источник", comment: "Укажите источник")
        }
        
        if !Validator.isValid(present: destinationId) {
            errors["destination_id"] = NSLocalizedString("Укажите назначение", comment: "Укажите назначение")
        }
        
        if !Validator.isValid(present: amountCurrency) {
            errors["amount_currency"] = NSLocalizedString("Укажите валюту", comment: "Укажите валюту")
        }
        
        if !Validator.isValid(present: convertedAmountCurrency) {
            errors["converted_amount_currency"] = NSLocalizedString("Укажите валюту конвертации", comment: "Укажите валюту конвертации")
        }
        
        if !Validator.isValid(positiveMoney: amountCents) {
            errors["amount"] = NSLocalizedString("Укажите сумму списания", comment: "Укажите сумму списания")
        }
        
        if !Validator.isValid(positiveMoney: convertedAmountCents) {
            errors["converted_amount"] = NSLocalizedString("Укажите сумму зачисления", comment: "Укажите сумму зачисления")
        }
        
        if !Validator.isValid(pastDate: gotAt) {
            errors["got_at"] = NSLocalizedString("Укажите дату транзакции", comment: "Укажите дату транзакции")
        }
        
        return errors
    }
}
