//
//  IncomeEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum IncomeUpdatingError : Error {
    case updatingIncomeIsNotSpecified
}

class IncomeEditViewModel : TransactionEditViewModel {
    private let incomesCoordinator: IncomesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var income: Income? = nil    
    
    var incomeSourceStartable: IncomeSourceViewModel? {
        return startable as? IncomeSourceViewModel
    }
    
    var expenseSourceCompletable: ExpenseSourceViewModel? {
        return completable as? ExpenseSourceViewModel
    }
    
    override var title: String { return isNew ? "Новый доход" : "Изменить доход" }
    
    override var removeTitle: String? { return isNew ? nil : "Удалить доход" }
    
    override var startableTitle: String? { return "Источник доходов" }
    
    override var completableTitle: String? { return "Кошелек для пополнения" }
        
    override var startableIconDefaultImageName: String { return "lamp-icon" }
    
    override var completableIconDefaultImageName: String { return "expense-source-icon" }
    
    var isChild: Bool {
        return incomeSourceStartable?.isChild ?? false
    }
    
    var ableToCloseActive: Bool {
        return isNew && isChild
    }
    
    var shouldCloseActive: Bool = false
    
    init(incomesCoordinator: IncomesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.incomesCoordinator = incomesCoordinator
        self.accountCoordinator = accountCoordinator
        super.init(exchangeRatesCoordinator: exchangeRatesCoordinator, currencyConverter: currencyConverter)
    }
    
    func set(incomeId: Int) {
        transactionableId = incomeId
    }
    
    func set(income: Income) {
        self.income = income
        self.comment = income.comment
        self.gotAt = income.gotAt
        self.startable = IncomeSourceViewModel(incomeSource: income.incomeSource)
        self.completable = ExpenseSourceViewModel(expenseSource: income.expenseSource)
        self.amount = income.amountCents.moneyDecimalString(with: startableCurrency)
        self.convertedAmount = income.convertedAmountCents.moneyDecimalString(with: completableCurrency)
    }
    
    func set(startable: IncomeSourceViewModel, completable: ExpenseSourceViewModel) {
        self.startable = startable
        self.completable = completable
    }
    
    override func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return  firstly {
                    incomesCoordinator.show(by: transactionableId)
                }.get { income in
                    self.set(income: income)
                }.asVoid()
    }
    
    func removeIncome() -> Promise<Void> {
        guard let incomeId = income?.id else {
            return Promise(error: IncomeUpdatingError.updatingIncomeIsNotSpecified)
        }
        return incomesCoordinator.destroy(by: incomeId)
    }
    
    override func create() -> Promise<Void> {
        return incomesCoordinator.create(with: creationForm(), closeActive: shouldCloseActive).asVoid()
    }
    
    override func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    override func update() -> Promise<Void> {
        return incomesCoordinator.update(with: updatingForm())
    }
    
    override func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
}

// Creation
extension IncomeEditViewModel {
    private func creationForm() -> IncomeCreationForm {
        return IncomeCreationForm(userId: accountCoordinator.currentSession?.userId,
                                  incomeSourceId: incomeSourceStartable?.id,
                                  expenseSourceId: expenseSourceCompletable?.id,
                                  amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                  amountCurrency: startableCurrency?.code,
                                  convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                  convertedAmountCurrency: completableCurrency?.code,
                                  gotAt: gotAt ?? Date(),
                                  comment: comment)
    }
}

// Updating
extension IncomeEditViewModel {
    private func updatingForm() -> IncomeUpdatingForm {
        return IncomeUpdatingForm(id: income?.id,
                                  incomeSourceId: incomeSourceStartable?.id,
                                  expenseSourceId: expenseSourceCompletable?.id,
                                  amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                  amountCurrency: startableCurrency?.code,
                                  convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                  convertedAmountCurrency: completableCurrency?.code,
                                  gotAt: gotAt,
                                  comment: comment)
    }
}
