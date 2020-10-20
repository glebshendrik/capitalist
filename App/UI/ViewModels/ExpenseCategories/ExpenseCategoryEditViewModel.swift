//
//  ExpenseCategoryEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseCategoryCreationError : Error {
    case basketIsNotSpecified
}

enum ExpenseCategoryUpdatingError : Error {
    case updatingExpenseCategoryIsNotSpecified
}

class ExpenseCategoryEditViewModel : TransactionableExamplesDependantProtocol {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    var transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    
    public private(set) var expenseCategory: ExpenseCategory? = nil
    var basketType: BasketType = .joy
    
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil
    var monthlyPlanned: String? = nil
    var description: String? = nil
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    // Computed
    
    var defaultIconName: String {
        return TransactionableType.expenseCategory.defaultIconName(basketType: basketType)
    }
    
    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
        
    var isNew: Bool {
        return expenseCategory == nil
    }
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet
            ? NSLocalizedString("Изменить напоминание", comment: "Изменить напоминание")
            : NSLocalizedString("Установить напоминание", comment: "Установить напоминание")
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
    
    // Permissions
    
    var canChangeCurrency: Bool {
        return isNew
    }
    
    var canChangeIncomeSourceCurrency: Bool {
        return isNew && basketType != .joy
    }
    
    // Visibility
    
    var reminderHidden: Bool {
        return !isNew
    }
    
    var removeButtonHidden: Bool {
        return isNew
    }
    
    var incomeSourceCurrencyHidden: Bool {
        return basketType == .joy
    }
    
    var numberOfUnusedExamples: Int = 0
        
    var example: TransactionableExampleViewModel? = nil
    
    init(expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        self.accountCoordinator = accountCoordinator
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadExamples())
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
        
    func set(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
        basketType = expenseCategory.basketType
        name = expenseCategory.name
        selectedIconURL = expenseCategory.iconURL
        selectedCurrency = expenseCategory.currency        
        monthlyPlanned = expenseCategory.monthlyPlannedCents?.moneyDecimalString(with: selectedCurrency)
        description = expenseCategory.description
        reminderViewModel = ReminderViewModel(reminder: expenseCategory.reminder)
    }
    
    func set(example: TransactionableExampleViewModel) {
        self.example = example
        selectedIconURL = example.iconURL
        name = example.name
        description = example.description
    }
    
    func set(basketType: BasketType) {
        self.basketType = basketType
    }
    
    func isFormValid() -> Bool {
        return isNew
            ? isCreationFormValid()
            : isUpdatingFormValid()
    }
    
    func save() -> Promise<Void> {
        return isNew
            ? create()
            : update()
    }
    
    func removeExpenseCategory(deleteTransactions: Bool) -> Promise<Void> {
        guard let expenseCategoryId = expenseCategory?.id else {
            return Promise(error: ExpenseCategoryUpdatingError.updatingExpenseCategoryIsNotSpecified)
        }
        return expenseCategoriesCoordinator.destroy(by: expenseCategoryId, deleteTransactions: deleteTransactions)
    }
    
    func basketId(by basketType: BasketType?) -> Int? {
        guard
            let session = accountCoordinator.currentSession,
            let basketType = basketType
        else {
            return nil
        }
        
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
    private func create() -> Promise<Void> {
        return expenseCategoriesCoordinator.create(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ExpenseCategoryCreationForm {
        return ExpenseCategoryCreationForm(basketId: basketId(by: basketType),
                                           iconURL: selectedIconURL,
                                           name: name,
                                           currency: selectedCurrencyCode,
                                           monthlyPlannedCents: monthlyPlanned?.intMoney(with: selectedCurrency),
                                           description: description,
                                           prototypeKey: example?.prototypeKey,
                                           reminderAttributes: reminderViewModel.reminderAttributes)
    }
}

// Updating
extension ExpenseCategoryEditViewModel {
    private func update() -> Promise<Void> {
        return expenseCategoriesCoordinator.update(with: updatingForm())
    }
    
    private func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> ExpenseCategoryUpdatingForm {
        return ExpenseCategoryUpdatingForm(id: expenseCategory?.id,
                                           iconURL: selectedIconURL,
                                           name: name,
                                           monthlyPlannedCents: monthlyPlanned?.intMoney(with: selectedCurrency),
                                           description: description,
                                           reminderAttributes: reminderViewModel.reminderAttributes)
    }
}
