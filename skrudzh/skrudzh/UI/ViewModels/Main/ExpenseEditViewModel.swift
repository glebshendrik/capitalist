//
//  ExpenseEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseCreationError : Error {
    case validation(validationResults: [ExpenseCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
    case currencyIsNotSpecified
    case expenseSourceIsNotSpecified
    case expenseCategoryIsNotSpecified
}

enum ExpenseUpdatingError : Error {
    case validation(validationResults: [ExpenseUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingExpenseIsNotSpecified
    case currencyIsNotSpecified
    case expenseSourceIsNotSpecified
    case expenseCategoryIsNotSpecified
}


class ExpenseEditViewModel : TransactionEditViewModel {
    private let expensesCoordinator: ExpensesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var expense: Expense? = nil
        
    var expenseSourceStartable: ExpenseSourceViewModel? {
        return startable as? ExpenseSourceViewModel
    }
    
    var expenseCategoryCompletable: ExpenseCategoryViewModel? {
        return completable as? ExpenseCategoryViewModel
    }
    
    override var title: String? {
        return isNew ? "Новая трата" : "Изменить трату"
    }
    
    override var removeTitle: String? {
        return isNew ? nil : "Удалить трату"
    }
    
    override var startableTitle: String? {
        return "Кошелек"
    }
    
    override var completableTitle: String? {
        return "Категория расходов"
    }
    
    override var startableAmountTitle: String? {
        return "Сумма списания"
    }
    
    override var completableAmountTitle: String? {
        return "Сумма расхода"
    }
    
    override var amount: String? {
        guard let currency = startableCurrency else { return nil }
        return expense?.amountCents.moneyDecimalString(with: currency)
    }
    
    override var convertedAmount: String? {
        guard let convertedCurrency = completableCurrency else { return nil }
        return expense?.convertedAmountCents.moneyDecimalString(with: convertedCurrency)
    }
    
    override var startableIconDefaultImageName: String {
        return "expense-source-icon"
    }
    
    override var completableIconDefaultImageName: String {
        let basketType = expenseCategoryCompletable?.basketType ?? .joy
        
        switch basketType {
        case .joy:
            return "joy-default-icon"
        case .risk:
            return "risk-default-icon"
        case .safe:
            return "safe-default-icon"
        }
    }
    
    var ableToIncludeInBalance: Bool {
        guard let expense = expense else { return false }
        return expense.expenseCategory.basketType != .joy
    }
    
    var includedInBalance: Bool = false
    
    init(expensesCoordinator: ExpensesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.expensesCoordinator = expensesCoordinator
        self.accountCoordinator = accountCoordinator
        super.init(exchangeRatesCoordinator: exchangeRatesCoordinator, currencyConverter: currencyConverter)
    }
    
    func set(expenseId: Int) {
        transactionableId = expenseId
    }
    
    func set(expense: Expense) {
        self.expense = expense
        self.comment = expense.comment
        self.gotAt = expense.gotAt
        self.includedInBalance = expense.includedInBalance
        self.startable = ExpenseSourceViewModel(expenseSource: expense.expenseSource)
        self.completable = ExpenseCategoryViewModel(expenseCategory: expense.expenseCategory)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseCategoryViewModel) {
        self.startable = startable
        self.completable = completable
    }
    
    override func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return  firstly {
                    expensesCoordinator.show(by: transactionableId)
                }.get { expense in
                    self.set(expense: expense)
                }.asVoid()
    }
    
    func isFormValid(amount: String?,
                     convertedAmount: String?,
                     comment: String?,
                     gotAt: Date?) -> Bool {
        
        guard let currency = startableCurrency,
            let convertedCurrency = completableCurrency else { return false }
        
        let amountCents = amount?.intMoney(with: currency)
        let convertedAmountCents = convertedAmount?.intMoney(with: convertedCurrency)
        
        return isNew
            ? isCreationFormValid(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            : isUpdatingFormValid(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
    }
    
    func saveExpense(amount: String?,
                    convertedAmount: String?,
                    comment: String?,
                    gotAt: Date?) -> Promise<Void> {
        
        guard   let currency = startableCurrency,
            let convertedCurrency = completableCurrency else {
                
                return Promise(error: ExpenseCreationError.currencyIsNotSpecified)
        }
        
        let amountCents = amount?.intMoney(with: currency)
        let convertedAmountCents = convertedAmount?.intMoney(with: convertedCurrency)
        
        return isNew
            ? createExpense(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            : updateExpense(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
    }
    
    func removeExpense() -> Promise<Void> {
        guard let expenseId = expense?.id else {
            return Promise(error: ExpenseUpdatingError.updatingExpenseIsNotSpecified)
        }
        return expensesCoordinator.destroy(by: expenseId)
    }
}

// Creation
extension ExpenseEditViewModel {
    private func isCreationFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func createExpense(amountCents: Int?,
                              convertedAmountCents: Int?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return  firstly {
            validateCreationForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            }.then { expenseCreationForm -> Promise<Expense> in
                self.expensesCoordinator.create(with: expenseCreationForm)
            }.asVoid()
    }
    
    private func validateCreationForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<ExpenseCreationForm> {
        
        if let failureResultsHash = validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: ExpenseCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: ExpenseCreationError.currentSessionDoesNotExist)
        }
        
        guard   let currencyCode = startableCurrency?.code,
            let convertedCurrencyCode = completableCurrency?.code else {
                return Promise(error: ExpenseCreationError.currencyIsNotSpecified)
        }
        
        guard let expenseSourceId = expenseSourceStartable?.id else {
            return Promise(error: ExpenseCreationError.expenseSourceIsNotSpecified)
        }
        
        guard let expenseCategoryId = expenseCategoryCompletable?.id else {
            return Promise(error: ExpenseCreationError.expenseCategoryIsNotSpecified)
        }
        
        return .value(ExpenseCreationForm(userId: currentUserId,
                                         expenseSourceId: expenseSourceId,
                                         expenseCategoryId: expenseCategoryId,
                                         amountCents: amountCents!,
                                         amountCurrency: currencyCode,
                                         convertedAmountCents: convertedAmountCents!,
                                         convertedAmountCurrency: convertedCurrencyCode,
                                         gotAt: gotAt!,
                                         comment: comment,
                                         includedInBalance: includedInBalance))
    }
    
    private func validateCreation(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [ExpenseCreationForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: ExpenseCreationForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: ExpenseCreationForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: ExpenseCreationForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [ExpenseCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension ExpenseEditViewModel {
    private func isUpdatingFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func updateExpense(amountCents: Int?,
                              convertedAmountCents: Int?,
                              comment: String?,
                              gotAt: Date?) -> Promise<Void> {
        return  firstly {
            validateUpdatingForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            }.then { expenseUpdatingForm -> Promise<Void> in
                self.expensesCoordinator.update(with: expenseUpdatingForm)
        }
    }
    
    private func validateUpdatingForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<ExpenseUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: ExpenseUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let expenseId = expense?.id else {
            return Promise(error: ExpenseUpdatingError.updatingExpenseIsNotSpecified)
        }
        
        guard   let currencyCode = startableCurrency?.code,
            let convertedCurrencyCode = completableCurrency?.code else {
                return Promise(error: ExpenseUpdatingError.currencyIsNotSpecified)
        }
        
        guard let expenseSourceId = expenseSourceStartable?.id else {
            return Promise(error: ExpenseUpdatingError.expenseSourceIsNotSpecified)
        }
        
        guard let expenseCategoryId = expenseCategoryCompletable?.id else {
            return Promise(error: ExpenseUpdatingError.expenseCategoryIsNotSpecified)
        }
        
        return .value(ExpenseUpdatingForm(id: expenseId,
                                         expenseSourceId: expenseSourceId,
                                         expenseCategoryId: expenseCategoryId,
                                         amountCents: amountCents!,
                                         amountCurrency: currencyCode,
                                         convertedAmountCents: convertedAmountCents!,
                                         convertedAmountCurrency: convertedCurrencyCode,
                                         gotAt: gotAt!,
                                         comment: comment,
                                         includedInBalance: includedInBalance))
    }
    
    private func validateUpdating(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [ExpenseUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: ExpenseUpdatingForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: ExpenseUpdatingForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: ExpenseUpdatingForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [ExpenseUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
