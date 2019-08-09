//
//  ExpenseEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseUpdatingError : Error {
    case updatingExpenseIsNotSpecified
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
    
    override var title: String { return isNew ? "Новая трата" : "Изменить трату" }
    
    override var removeTitle: String? { return isNew ? nil : "Удалить трату" }
    
    override var startableTitle: String? { return "Кошелек" }
    
    override var completableTitle: String? { return "Категория расходов" }
        
    override var startableIconDefaultImageName: String { return "expense-source-icon" }
    
    override var completableIconDefaultImageName: String {
        return (expenseCategoryCompletable?.basketType ?? .joy).iconCategory.defaultIconName
    }
    
    var ableToIncludeInBalance: Bool {
        let basketType = expenseCategoryCompletable?.basketType ?? .joy
        return basketType != .joy
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
        self.amount = expense.amountCents.moneyDecimalString(with: startableCurrency)
        self.convertedAmount = expense.convertedAmountCents.moneyDecimalString(with: completableCurrency)
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
    
    func removeExpense() -> Promise<Void> {
        guard let expenseId = expense?.id else {
            return Promise(error: ExpenseUpdatingError.updatingExpenseIsNotSpecified)
        }
        return expensesCoordinator.destroy(by: expenseId)
    }
    
    override func create() -> Promise<Void> {
        return expensesCoordinator.create(with: creationForm()).asVoid()
    }
    
    override func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    override func update() -> Promise<Void> {
        return expensesCoordinator.update(with: updatingForm())
    }
    
    override func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
}

// Creation
extension ExpenseEditViewModel {
    private func creationForm() -> ExpenseCreationForm {
        return ExpenseCreationForm(userId: accountCoordinator.currentSession?.userId,
                                   expenseSourceId: expenseSourceStartable?.id,
                                   expenseCategoryId: expenseCategoryCompletable?.id,
                                   amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                   amountCurrency: startableCurrency?.code,
                                   convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                   convertedAmountCurrency: completableCurrency?.code,
                                   gotAt: gotAt ?? Date(),
                                   comment: comment,
                                   includedInBalance: includedInBalance)
    }
}

// Updating
extension ExpenseEditViewModel {
    private func updatingForm() -> ExpenseUpdatingForm {
        return ExpenseUpdatingForm(id: expense?.id,
                                   expenseSourceId: expenseSourceStartable?.id,
                                   expenseCategoryId: expenseCategoryCompletable?.id,
                                   amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                   amountCurrency: startableCurrency?.code,
                                   convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                   convertedAmountCurrency: completableCurrency?.code,
                                   gotAt: gotAt,
                                   comment: comment,
                                   includedInBalance: includedInBalance)
    }
}
