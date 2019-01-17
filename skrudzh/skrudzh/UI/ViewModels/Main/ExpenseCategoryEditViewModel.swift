//
//  ExpenseCategoryEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseCategoryCreationError : Error {
    case validation(validationResults: [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]])
    case basketIsNotSpecified
}

enum ExpenseCategoryUpdatingError : Error {
    case validation(validationResults: [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingExpenseCategoryIsNotSpecified
}


class ExpenseCategoryEditViewModel {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var expenseCategory: ExpenseCategory? = nil
    public private(set) var basketType: BasketType? = nil
    
    var name: String? {
        return expenseCategory?.name
    }
    
    var monthlyPlanned: String? {
        return expenseCategory?.monthlyPlannedCents.moneyDecimalString
    }
    
    var iconURL: URL? {
        return expenseCategory?.iconURL
    }
    
    var selectedIconURL: URL?
    
    var isNew: Bool {
        return expenseCategory == nil
    }
    
    init(expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.accountCoordinator = accountCoordinator
    }
    
    func set(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
        selectedIconURL = iconURL
    }
    
    func set(basketType: BasketType) {
        self.basketType = basketType
    }
    
    func isFormValid(with name: String?,
                     iconURL: URL?,
                     monthlyPlanned: String?) -> Bool {
        let monthlyPlannedCents = monthlyPlanned?.intMoney
        return isNew
            ? isCreationFormValid(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
            : isUpdatingFormValid(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
    }
    
    func saveExpenseCategory(with name: String?,
                             iconURL: URL?,
                             monthlyPlanned: String?) -> Promise<Void> {
        let monthlyPlannedCents = monthlyPlanned?.intMoney
        return isNew
            ? createExpenseCategory(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
            : updateExpenseCategory(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
    }
    
    func removeExpenseCategory() -> Promise<Void> {
        guard let expenseCategoryId = expenseCategory?.id else {
            return Promise(error: ExpenseCategoryUpdatingError.updatingExpenseCategoryIsNotSpecified)
        }
        return expenseCategoriesCoordinator.destroy(by: expenseCategoryId)
    }
    
    func basketId(by basketType: BasketType) -> Int? {
        guard let session = accountCoordinator.currentSession else { return nil }
        
        switch basketType {
        case .joy:
            return session.joyBasketId
        case .risk:
            return session.riskBasketId
        case .safe:
            return session.safeBasketId
        }
    }
}

// Creation
extension ExpenseCategoryEditViewModel {
    private func isCreationFormValid(with name: String?,
                                     iconURL: URL?,
                                     monthlyPlannedCents: Int?) -> Bool {
        return validateCreation(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) == nil
    }
    
    private func createExpenseCategory(with name: String?,
                                       iconURL: URL?,
                                       monthlyPlannedCents: Int?) -> Promise<Void> {
        return  firstly {
                    validateCreationForm(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
                }.then { expenseCategoryCreationForm -> Promise<ExpenseCategory> in
                    self.expenseCategoriesCoordinator.create(with: expenseCategoryCreationForm)
                }.asVoid()
    }
    
    private func validateCreationForm(with name: String?,
                                      iconURL: URL?,
                                      monthlyPlannedCents: Int?) -> Promise<ExpenseCategoryCreationForm> {
        
        if let failureResultsHash = validateCreation(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) {
            return Promise(error: ExpenseCategoryCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard   let basketType = basketType,
                let basketId = basketId(by: basketType) else {
            return Promise(error: ExpenseCategoryCreationError.basketIsNotSpecified)
        }
        
        return .value(ExpenseCategoryCreationForm(name: name!,
                                                  iconURL: iconURL,
                                                  basketId: basketId,
                                                  monthlyPlannedCents: monthlyPlannedCents!))
    }
    
    private func validateCreation(with name: String?,
                                  iconURL: URL?,
                                  monthlyPlannedCents: Int?) -> [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]]? {
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseCategoryCreationForm.CodingKeys.name),
             Validator.validate(money: monthlyPlannedCents, key: ExpenseCategoryCreationForm.CodingKeys.monthlyPlannedCents)]
        
        let failureResultsHash : [ExpenseCategoryCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension ExpenseCategoryEditViewModel {
    private func isUpdatingFormValid(with name: String?,
                                     iconURL: URL?,
                                     monthlyPlannedCents: Int?) -> Bool {
        return validateUpdating(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) == nil
    }
    
    private func updateExpenseCategory(with name: String?,
                                       iconURL: URL?,
                                       monthlyPlannedCents: Int?) -> Promise<Void> {
        return  firstly {
                    validateUpdatingForm(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents)
                }.then { expenseCategoryUpdatingForm in
                    self.expenseCategoriesCoordinator.update(with: expenseCategoryUpdatingForm)
                }
    }
    
    private func validateUpdatingForm(with name: String?,
                                      iconURL: URL?,
                                      monthlyPlannedCents: Int?) -> Promise<ExpenseCategoryUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(with: name, iconURL: iconURL, monthlyPlannedCents: monthlyPlannedCents) {
            return Promise(error: ExpenseCategoryUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let expenseCategoryId = expenseCategory?.id else {
            return Promise(error: ExpenseCategoryUpdatingError.updatingExpenseCategoryIsNotSpecified)
        }
        
        return .value(ExpenseCategoryUpdatingForm(id: expenseCategoryId,
                                                  name: name!,
                                                  iconURL: iconURL,
                                                  monthlyPlannedCents: monthlyPlannedCents!))
    }
    
    private func validateUpdating(with name: String?,
                                  iconURL: URL?,
                                  monthlyPlannedCents: Int?) -> [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(required: name, key: ExpenseCategoryUpdatingForm.CodingKeys.name),
             Validator.validate(money: monthlyPlannedCents, key: ExpenseCategoryUpdatingForm.CodingKeys.monthlyPlannedCents)]
        
        let failureResultsHash : [ExpenseCategoryUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}