//
//  FundsMoveEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 07/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

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
    
    var whomButtonTitle: String { return whom ?? whomPlaceholder }
    
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
    
    override var startableAmountTitle: String? { return "Сумма списания" }
    
    override var completableAmountTitle: String? { return "Сумма пополнения" }
    
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
        
        func amountDebt() -> String? {
            if let debtTransaction = debtTransaction {
                if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id == startable?.id {
                    return debtTransaction.debtAmountLeft
                }
                if !needCurrencyExchange && debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable?.id {
                    return debtTransaction.loanAmountLeft
                }
            }
            return nil
        }
        
        func convertedAmountDebt() -> String? {
            if let debtTransaction = debtTransaction {
                if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable?.id {
                    return debtTransaction.loanAmountLeft
                }
            }
            return nil
        }
        
        amount = fundsMove.amountCents.moneyDecimalString(with: startableCurrency) ?? amountDebt()
        convertedAmount = fundsMove.convertedAmountCents.moneyDecimalString(with: completableCurrency) ?? convertedAmountDebt()
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
                                     gotAt: gotAt,
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
