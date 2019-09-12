//
//  BorrowEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum TransactionError : Error {
    case transactionIsNotSpecified
}

class TransactionEditViewModel {
    private let exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol
    private let currencyConverter: CurrencyConverterProtocol
    
    var transactionableId: Int?
    
    var startable: TransactionStartable? = nil
    var completable: TransactionCompletable? = nil
    var amount: String? = nil {
        didSet {
            convertedAmountConverted = convert(amount: amount, isForwardConversion: true)
        }
    }
    var convertedAmount: String? = nil {
        didSet {
            amountConverted = convert(amount: convertedAmount, isForwardConversion: false)
        }
    }
    var comment: String? = nil
    var gotAt: Date? = nil
    var amountConverted: String? = nil
    var convertedAmountConverted: String? = nil
    
    var title: String { return "" }
    var removeTitle: String? { return nil }
    var removeQuestion: String? { return nil }
    var startableTitle: String? { return nil }
    var completableTitle: String? { return nil }
    var startableAmountTitle: String? { return "Сумма" }
    var completableAmountTitle: String? { return "Сумма" }
    var amountPlaceholder: String? {
        return amountConverted ?? startableAmountTitle
    }
    var convertedAmountPlaceholder: String? {
        return convertedAmountConverted ?? completableAmountTitle
    }
    
    var isNew: Bool { return transactionableId == nil }
    
    var hasComment: Bool {
        guard let comment = comment else { return false }
        return !comment.isEmpty && !comment.isWhitespace
    }
    
    var hasGotAtDate: Bool { return gotAt != nil }
    
    var calendarTitle: String {
        return hasGotAtDate ? gotAt!.dateTimeString(ofStyle: .short) : "Выбрать дату"
    }
    
    var startableIconURL: URL? { return startable?.iconURL }
    
    var startableIconDefaultImageName: String { return "" }
    
    var completableIconURL: URL? { return completable?.iconURL }
    
    var completableIconDefaultImageName: String { return "" }
    
    var startableName: String? { return startable?.name }
    
    var completableName: String? { return completable?.name }
    
    var startableAmount: String? { return startable?.amount }
    
    var completableAmount: String? { return completable?.amount }
    
    var startableCurrency: Currency? { return startable?.currency }
    
    var completableCurrency: Currency? { return completable?.currency }
    
    var startableCurrencyCode: String? { return startableCurrency?.code }
    
    var completableCurrencyCode: String? { return completableCurrency?.code }
    
    var needCurrencyExchange: Bool {
        return startableCurrency?.code != completableCurrency?.code
    }
    
    var exchangeRate: Float = 1.0
    
    var removeButtonHidden: Bool { return isNew }
    
    init(exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.exchangeRatesCoordinator = exchangeRatesCoordinator
        self.currencyConverter = currencyConverter
    }
    
    func loadData() -> Promise<Void> {
        if isNew {
            return loadExchangeRate()
        }
        return loadTransaction()
    }
    
    func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return Promise.value(())
    }
    
    func convert(amount: String?, isForwardConversion: Bool = true) -> String? {
        guard   let currency = startableCurrency,
            let convertedCurrency = completableCurrency,
            let amountCents = amount?.intMoney(with: isForwardConversion ? currency : convertedCurrency) else { return nil }
        
        let convertedAmountCents = currencyConverter.convert(cents: amountCents, fromCurrency: currency, toCurrency: convertedCurrency, exchangeRate: Double(exchangeRate), forward: isForwardConversion)
        
        return convertedAmountCents.moneyDecimalString(with: isForwardConversion ? convertedCurrency : currency)
    }
    
    func loadExchangeRate() -> Promise<Void> {
        guard   needCurrencyExchange,
            let fromCurrencyCode = startableCurrencyCode,
            let toCurrencyCode = completableCurrencyCode else {
                return Promise.value(())
        }
        return  firstly {
            exchangeRatesCoordinator.show(from: fromCurrencyCode, to: toCurrencyCode)
            }.done { exchangeRate in
                self.exchangeRate = exchangeRate.rate
        }
    }
    
    private func loadTransaction() -> Promise<Void> {
        guard let transactionableId = transactionableId else {
            return Promise(error: TransactionError.transactionIsNotSpecified)
        }
        return  firstly {
            loadTransactionPromise(transactionableId: transactionableId)
            }.then {
                self.loadExchangeRate()
        }
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
    
    func create() -> Promise<Void> {
        return Promise.value(())
    }
    
    func update() -> Promise<Void> {
        return Promise.value(())
    }
    
    func isCreationFormValid() -> Bool {
        return false
    }
    
    func isUpdatingFormValid() -> Bool {
        return false
    }
}

enum FundsMoveCreationError : Error {
    case debtDestinationIsNotEqualToReturnSource
    case loanSourceIsNotEqualToReturnDestination
}

enum FundsMoveUpdatingError : Error {
    case updatingFundsMoveIsNotSpecified
    case debtDestinationIsNotEqualToReturnSource
    case loanSourceIsNotEqualToReturnDestination
}

class FundsMoveEditViewModel : TransactionEditViewModel {
    private let fundsMovesCoordinator: FundsMovesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    
    private var fundsMove: FundsMove? = nil
    
    var expenseSourceFromStartable: ExpenseSourceViewModel? {
        return startable as? ExpenseSourceViewModel
    }
    
    var expenseSourceToCompletable: ExpenseSourceViewModel? {
        return completable as? ExpenseSourceViewModel
    }
    
    private var debtTransaction: FundsMoveViewModel?
    
    var whom: String? = nil
    var borrowedTill: Date? = nil
    
    var whomButtonTitle: String {
        if let whom = whom, !whom.isEmpty {
            return whom
        }
        return whomPlaceholder
    }
    
    var whomPlaceholder: String { return isLoan ? "У кого" : "Кому" }
    
    var borrowedTillButtonTitle: String? {
        if let borrowedTill = borrowedTill {
            return borrowedTill.dateString(ofStyle: .short)
        }
        return "Дата возврата"
    }
    
    var isDebtOrLoan: Bool { return isDebt || isLoan }
    
    var isDebt: Bool {
        guard !isReturn, let expenseSourceToCompletable = expenseSourceToCompletable else { return false }
        return expenseSourceToCompletable.isDebt
    }
    
    var isLoan: Bool {
        guard !isReturn, let expenseSourceFromStartable = expenseSourceFromStartable else { return false }
        return expenseSourceFromStartable.isDebt
    }
    
    var isReturn: Bool { return debtTransaction != nil }
    
    var isReturnOptionHidden: Bool {
        guard   let fundsMove = fundsMove,
            fundsMove.expenseSourceFrom.id == startable?.id,
            fundsMove.expenseSourceTo.id == completable?.id else { return true }
        return isNew || !isDebtOrLoan || fundsMove.isReturned
    }
    
    var returnTitle: String? {
        guard !isReturnOptionHidden else { return nil }
        if isLoan {
            return "Вернуть займ"
        }
        if isDebt {
            return "Вернуть долг"
        }
        return nil
    }
    
    override var title: String {
        switch (isNew, isDebt, isLoan, isReturn) {
        case   (true,  true,   false,  false):  return "Новый долг"
        case   (true,  false,  true,   false):  return "Новый займ"
        case   (true,  false,  false,  false):  return "Новый перевод"
        case   (true,  false,  false,  true):   return "Новый возврат"
        case   (false, true,   false,  false):  return "Изменить долг"
        case   (false, false,  true,   false):  return "Изменить займ"
        case   (false, false,  false,  false):  return "Изменить перевод"
        case   (false, false,  false,  true):   return "Изменить возврат"
        default: return "Новый перевод"
        }
    }
    
    override var removeTitle: String? { return isNew ? nil : "Удалить перевод" }
    
    override var startableTitle: String? { return "Кошелек снятия" }
    
    override var completableTitle: String? { return "Кошелек пополнения" }
    
    override var startableIconDefaultImageName: String { return "expense-source-icon" }
    
    override var completableIconDefaultImageName: String { return "expense-source-icon" }
    
    init(fundsMovesCoordinator: FundsMovesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.fundsMovesCoordinator = fundsMovesCoordinator
        self.accountCoordinator = accountCoordinator
        super.init(exchangeRatesCoordinator: exchangeRatesCoordinator, currencyConverter: currencyConverter)
    }
    
    func set(fundsMoveId: Int) {
        transactionableId = fundsMoveId
    }
    
    func set(fundsMove: FundsMove) {
        self.fundsMove = fundsMove
        self.comment = fundsMove.comment
        self.gotAt = fundsMove.gotAt
        self.whom = fundsMove.whom
        self.borrowedTill = fundsMove.borrowedTill
        if let debtTransaction = fundsMove.debtTransaction {
            self.debtTransaction = FundsMoveViewModel(fundsMove: debtTransaction)
        }
        self.startable = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceFrom)
        self.completable = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceTo)
        self.amount = fundsMove.amountCents.moneyDecimalString(with: startableCurrency)
        self.convertedAmount = fundsMove.convertedAmountCents.moneyDecimalString(with: completableCurrency)
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
        self.startable = startable
        self.completable = completable
        self.debtTransaction = debtTransaction
        func amountDebt() -> String? {
            if let debtTransaction = debtTransaction {
                if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id == startable.id {
                    return debtTransaction.debtAmountLeft
                }
                if !needCurrencyExchange && debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable.id {
                    return debtTransaction.loanAmountLeft
                }
            }
            return nil
        }
        
        func convertedAmountDebt() -> String? {
            if let debtTransaction = debtTransaction {
                if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable.id {
                    return debtTransaction.loanAmountLeft
                }
            }
            return nil
        }
        
        self.amount = amountDebt()
        self.convertedAmount = convertedAmountDebt()
    }
    
    func asDebtTransactionForReturn() -> FundsMoveViewModel? {
        guard let fundsMove = fundsMove else { return nil }
        return FundsMoveViewModel(fundsMove: fundsMove)
    }
    
    override func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return  firstly {
            fundsMovesCoordinator.show(by: transactionableId)
            }.get { fundsMove in
                self.set(fundsMove: fundsMove)
            }.asVoid()
    }
    
    func removeFundsMove() -> Promise<Void> {
        guard let fundsMoveId = fundsMove?.id else {
            return Promise(error: FundsMoveUpdatingError.updatingFundsMoveIsNotSpecified)
        }
        return fundsMovesCoordinator.destroy(by: fundsMoveId)
    }
    
    override func create() -> Promise<Void> {
        if let debtTransaction = debtTransaction {
            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
                return Promise(error: FundsMoveCreationError.debtDestinationIsNotEqualToReturnSource)
            }
            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
                return Promise(error: FundsMoveCreationError.loanSourceIsNotEqualToReturnDestination)
            }
        }
        return fundsMovesCoordinator.create(with: creationForm()).asVoid()
    }
    
    override func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    override func update() -> Promise<Void> {
        if let debtTransaction = debtTransaction {
            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
                return Promise(error: FundsMoveUpdatingError.debtDestinationIsNotEqualToReturnSource)
            }
            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
                return Promise(error: FundsMoveUpdatingError.loanSourceIsNotEqualToReturnDestination)
            }
        }
        return fundsMovesCoordinator.update(with: updatingForm())
    }
    
    override func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
}

// Creation
extension FundsMoveEditViewModel {
    private func creationForm() -> FundsMoveCreationForm {
        return FundsMoveCreationForm(userId: accountCoordinator.currentSession?.userId,
                                     expenseSourceFromId: expenseSourceFromStartable?.id,
                                     expenseSourceToId: expenseSourceToCompletable?.id,
                                     amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                     amountCurrency: startableCurrency?.code,
                                     convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                     convertedAmountCurrency: completableCurrency?.code,
                                     gotAt: gotAt ?? Date(),
                                     comment: comment,
                                     whom: whom,
                                     borrowedTill: borrowedTill,
                                     debtTransactionId: debtTransaction?.id)
    }
}

// Updating
extension FundsMoveEditViewModel {
    private func updatingForm() -> FundsMoveUpdatingForm {
        return FundsMoveUpdatingForm(id: fundsMove?.id,
                                     expenseSourceFromId: expenseSourceFromStartable?.id,
                                     expenseSourceToId: expenseSourceToCompletable?.id,
                                     amountCents: (amount ?? amountConverted)?.intMoney(with: startableCurrency),
                                     amountCurrency: startableCurrency?.code,
                                     convertedAmountCents: (convertedAmount ?? convertedAmountConverted)?.intMoney(with: completableCurrency),
                                     convertedAmountCurrency: completableCurrency?.code,
                                     gotAt: gotAt,
                                     comment: comment,
                                     whom: whom,
                                     borrowedTill: borrowedTill)
    }
}
