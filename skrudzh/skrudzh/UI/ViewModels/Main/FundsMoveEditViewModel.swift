//
//  FundsMoveEditViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

enum FundsMoveCreationError : Error {
    case validation(validationResults: [FundsMoveCreationForm.CodingKeys : [ValidationErrorReason]])
    case currentSessionDoesNotExist
    case currencyIsNotSpecified
    case expenseSourceFromIsNotSpecified
    case expenseSourceToIsNotSpecified
    case debtDestinationIsNotEqualToReturnSource
    case loanSourceIsNotEqualToReturnDestination
}

enum FundsMoveUpdatingError : Error {
    case validation(validationResults: [FundsMoveUpdatingForm.CodingKeys : [ValidationErrorReason]])
    case updatingFundsMoveIsNotSpecified
    case currencyIsNotSpecified
    case expenseSourceFromIsNotSpecified
    case expenseSourceToIsNotSpecified
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
        if let whom = whom {
            return whom
        }        
        return whomPlaceholder
    }
    
    var whomPlaceholder: String {
        if isLoan {
            return "У кого"
        }
        return "Кому"
    }
    
    var borrowedTillButtonTitle: String? {
        if let borrowedTill = borrowedTill {
            return borrowedTill.dateString(ofStyle: .short)
        }
        return "Дата возврата"
    }
    
    var isDebtOrLoan: Bool {
        return isDebt || isLoan
    }
    
    var isDebt: Bool {
        guard !isReturn, let expenseSourceToCompletable = expenseSourceToCompletable else { return false }
        return expenseSourceToCompletable.isDebt
    }
    
    var isLoan: Bool {
        guard !isReturn, let expenseSourceFromStartable = expenseSourceFromStartable else { return false }
        return expenseSourceFromStartable.isDebt
    }
    
    var isReturn: Bool {
        return debtTransaction != nil
    }
        
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
    
    override var title: String? {
        switch (isNew, isDebt, isLoan, isReturn) {
        case   (true,  true,   false,  false):  return "Новый долг"
        case   (true,  false,  true,   false):  return "Новый займ"
        case   (true,  false,  false,  false):  return "Новый перевод"
        case   (true,  false,  false,  true):   return "Новый возврат"
        case   (false, true,   false,  false):  return "Изменить долг"
        case   (false, false,  true,   false):  return "Изменить займ"
        case   (false, false,  false,  false):  return "Изменить перевод"
        case   (false, false,  false,  true):   return "Изменить возврат"
        default: return nil
        }
    }
    
    override var removeTitle: String? {
        return isNew ? nil : "Удалить перевод"
    }
    
    override var startableTitle: String? {
        return "Кошелек снятия"
    }
    
    override var completableTitle: String? {
        return "Кошелек пополнения"
    }
    
    override var startableAmountTitle: String? {
        return "Сумма списания"
    }
    
    override var completableAmountTitle: String? {
        return "Сумма пополнения"
    }
    
    override var amount: String? {
        guard let currency = startableCurrency else { return nil }
        if let fundsMoveAmount = fundsMove?.amountCents.moneyDecimalString(with: currency) {
            return fundsMoveAmount
        }
        if let debtTransaction = debtTransaction {
            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id == startable?.id {
                return debtTransaction.convertedAmountCents.moneyDecimalString(with: debtTransaction.convertedCurrency)
            }
            if !needCurrencyExchange && debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable?.id {
                return debtTransaction.amountCents.moneyDecimalString(with: debtTransaction.currency)
            }
        }
        
        return nil
    }
    
    override var convertedAmount: String? {
        guard let convertedCurrency = completableCurrency else { return nil }
        if let fundsMoveAmount = fundsMove?.convertedAmountCents.moneyDecimalString(with: convertedCurrency) {
            return fundsMoveAmount
        }
        if let debtTransaction = debtTransaction {
            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable?.id {
                return debtTransaction.amountCents.moneyDecimalString(with: debtTransaction.currency)
            }
        }
        return nil
    }
    
    override var startableIconDefaultImageName: String {
        return "expense-source-icon"
    }
    
    override var completableIconDefaultImageName: String {
        return "expense-source-icon"
    }
    
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
    }
    
    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
        self.startable = startable
        self.completable = completable
        self.debtTransaction = debtTransaction
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
    
    func saveFundsMove(amount: String?,
                     convertedAmount: String?,
                     comment: String?,
                     gotAt: Date?) -> Promise<Void> {
        
        guard   let currency = startableCurrency,
            let convertedCurrency = completableCurrency else {
                
                return Promise(error: FundsMoveCreationError.currencyIsNotSpecified)
        }
        
        let amountCents = amount?.intMoney(with: currency)
        let convertedAmountCents = convertedAmount?.intMoney(with: convertedCurrency)
        
        return isNew
            ? createFundsMove(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            : updateFundsMove(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
    }
    
    func removeFundsMove() -> Promise<Void> {
        guard let fundsMoveId = fundsMove?.id else {
            return Promise(error: FundsMoveUpdatingError.updatingFundsMoveIsNotSpecified)
        }
        return fundsMovesCoordinator.destroy(by: fundsMoveId)
    }
}

// Creation
extension FundsMoveEditViewModel {
    private func isCreationFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func createFundsMove(amountCents: Int?,
                               convertedAmountCents: Int?,
                               comment: String?,
                               gotAt: Date?) -> Promise<Void> {
        return  firstly {
            validateCreationForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            }.then { fundsMoveCreationForm -> Promise<FundsMove> in
                self.fundsMovesCoordinator.create(with: fundsMoveCreationForm)
            }.asVoid()
    }
    
    private func validateCreationForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<FundsMoveCreationForm> {
        
        if let failureResultsHash = validateCreation(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: FundsMoveCreationError.validation(validationResults: failureResultsHash))
        }
        
        guard let currentUserId = accountCoordinator.currentSession?.userId else {
            return Promise(error: FundsMoveCreationError.currentSessionDoesNotExist)
        }
        
        guard   let currencyCode = startableCurrency?.code,
            let convertedCurrencyCode = completableCurrency?.code else {
                return Promise(error: FundsMoveCreationError.currencyIsNotSpecified)
        }
        
        guard let expenseSourceFromId = expenseSourceFromStartable?.id else {
            return Promise(error: FundsMoveCreationError.expenseSourceFromIsNotSpecified)
        }
        
        guard let expenseSourceToId = expenseSourceToCompletable?.id else {
            return Promise(error: FundsMoveCreationError.expenseSourceToIsNotSpecified)
        }
        
        if let debtTransaction = debtTransaction {
            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
                return Promise(error: FundsMoveCreationError.debtDestinationIsNotEqualToReturnSource)
            }
            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
                return Promise(error: FundsMoveCreationError.loanSourceIsNotEqualToReturnDestination)
            }
        }
        
        return .value(FundsMoveCreationForm(userId: currentUserId,
                                          expenseSourceFromId: expenseSourceFromId,
                                          expenseSourceToId: expenseSourceToId,
                                          amountCents: amountCents!,
                                          amountCurrency: currencyCode,
                                          convertedAmountCents: convertedAmountCents!,
                                          convertedAmountCurrency: convertedCurrencyCode,
                                          gotAt: gotAt!,
                                          comment: comment,
                                          whom: whom,
                                          borrowedTill: borrowedTill,
                                          debtTransactionId: debtTransaction?.id))
    }
    
    private func validateCreation(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [FundsMoveCreationForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: FundsMoveCreationForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: FundsMoveCreationForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: FundsMoveCreationForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [FundsMoveCreationForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}

// Updating
extension FundsMoveEditViewModel {
    private func isUpdatingFormValid(amountCents: Int?,
                                     convertedAmountCents: Int?,
                                     comment: String?,
                                     gotAt: Date?) -> Bool {
        return validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) == nil
    }
    
    private func updateFundsMove(amountCents: Int?,
                               convertedAmountCents: Int?,
                               comment: String?,
                               gotAt: Date?) -> Promise<Void> {
        return  firstly {
            validateUpdatingForm(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt)
            }.then { fundsMoveUpdatingForm -> Promise<Void> in
                self.fundsMovesCoordinator.update(with: fundsMoveUpdatingForm)
        }
    }
    
    private func validateUpdatingForm(amountCents: Int?,
                                      convertedAmountCents: Int?,
                                      comment: String?,
                                      gotAt: Date?) -> Promise<FundsMoveUpdatingForm> {
        
        if let failureResultsHash = validateUpdating(amountCents: amountCents, convertedAmountCents: convertedAmountCents, comment: comment, gotAt: gotAt) {
            return Promise(error: FundsMoveUpdatingError.validation(validationResults: failureResultsHash))
        }
        
        guard let fundsMoveId = fundsMove?.id else {
            return Promise(error: FundsMoveUpdatingError.updatingFundsMoveIsNotSpecified)
        }
        
        guard   let currencyCode = startableCurrency?.code,
            let convertedCurrencyCode = completableCurrency?.code else {
                return Promise(error: FundsMoveUpdatingError.currencyIsNotSpecified)
        }
        
        guard let expenseSourceFromId = expenseSourceFromStartable?.id else {
            return Promise(error: FundsMoveUpdatingError.expenseSourceFromIsNotSpecified)
        }
        
        guard let expenseSourceToId = expenseSourceToCompletable?.id else {
            return Promise(error: FundsMoveUpdatingError.expenseSourceToIsNotSpecified)
        }
        
        if let debtTransaction = debtTransaction {
            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
                return Promise(error: FundsMoveUpdatingError.debtDestinationIsNotEqualToReturnSource)
            }
            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
                return Promise(error: FundsMoveUpdatingError.loanSourceIsNotEqualToReturnDestination)
            }
        }
        
        return .value(FundsMoveUpdatingForm(id: fundsMoveId,
                                          expenseSourceFromId: expenseSourceFromId,
                                          expenseSourceToId: expenseSourceToId,
                                          amountCents: amountCents!,
                                          amountCurrency: currencyCode,
                                          convertedAmountCents: convertedAmountCents!,
                                          convertedAmountCurrency: convertedCurrencyCode,
                                          gotAt: gotAt!,
                                          comment: comment,
                                          whom: whom,
                                          borrowedTill: borrowedTill))
    }
    
    private func validateUpdating(amountCents: Int?,
                                  convertedAmountCents: Int?,
                                  comment: String?,
                                  gotAt: Date?) -> [FundsMoveUpdatingForm.CodingKeys : [ValidationErrorReason]]? {
        
        let validationResults : [ValidationResultProtocol] =
            [Validator.validate(pastDate: gotAt, key: FundsMoveUpdatingForm.CodingKeys.gotAt),
             Validator.validate(positiveMoney: amountCents, key: FundsMoveUpdatingForm.CodingKeys.amountCents),
             Validator.validate(positiveMoney: convertedAmountCents, key: FundsMoveUpdatingForm.CodingKeys.convertedAmountCents)]
        
        let failureResultsHash : [FundsMoveUpdatingForm.CodingKeys : [ValidationErrorReason]]? = Validator.failureResultsHash(from: validationResults)
        
        return failureResultsHash
    }
}
