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
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    private var fundsMove: FundsMove? = nil    
    
    var expenseSourceFromStartable: ExpenseSourceViewModel? {
        return startable as? ExpenseSourceViewModel
    }
    
    var expenseSourceToCompletable: ExpenseSourceViewModel? {
        return completable as? ExpenseSourceViewModel
    }
    
//    private var debtTransaction: FundsMoveViewModel?
    private var borrow: BorrowViewModel?
    
    typealias ExpenseSourcesFilterOptions = (noDebts: Bool, accountType: AccountType?, currency: String?)
    
    enum ExpenseSourcesFilter {
        case noDebts
        case debts(currency: String?)
        
        var options: ExpenseSourcesFilterOptions {
            switch self {
            case .noDebts:
                return (noDebts: true, accountType: nil, currency: nil)
            case .debts(let currency):
                return (noDebts: false, accountType: .debt, currency: currency)
            }
        }
    }
    
    var isReturningDebt: Bool {
        return isReturn && borrow!.isDebt
    }
    
    var isReturningLoan: Bool {
        return isReturn && borrow!.isDebt
    }
    
    var startableFilter: ExpenseSourcesFilter {
        return isReturningDebt
            ? ExpenseSourcesFilter.debts(currency: borrow?.currency.code)
            : ExpenseSourcesFilter.noDebts
    }
    
    var completableFilter: ExpenseSourcesFilter {
        return isReturningLoan
            ? ExpenseSourcesFilter.debts(currency: borrow?.currency.code)
            : ExpenseSourcesFilter.noDebts
    }
    
//    var isDebtOrLoan: Bool { return isDebt || isLoan }
//    
//    var isDebt: Bool {
//        guard !isReturn, let expenseSourceToCompletable = expenseSourceToCompletable else { return false }
//        return expenseSourceToCompletable.isDebt
//    }
//    
//    var isLoan: Bool {
//        guard !isReturn, let expenseSourceFromStartable = expenseSourceFromStartable else { return false }
//        return expenseSourceFromStartable.isDebt
//    }
    
    var isReturn: Bool { return borrow != nil }
        
//    var isReturnOptionHidden: Bool {
//        guard   let fundsMove = fundsMove,
//                fundsMove.expenseSourceFrom.id == startable?.id,
//                fundsMove.expenseSourceTo.id == completable?.id else { return true }
//        return isNew || !isDebtOrLoan || fundsMove.isReturned
//    }
//
//    var returnTitle: String? {
//        guard !isReturnOptionHidden else { return nil }
//        if isLoan {
//            return "Вернуть займ"
//        }
//        if isDebt {
//            return "Вернуть долг"
//        }
//        return nil
//    }
//
    override var title: String {
        switch (isNew, isReturn) {
        case   (true,  false):  return "Новый перевод"
        case   (true,  true):   return "Новый возврат"
        case   (false, false):  return "Изменить перевод"
        case   (false,  true):   return "Изменить возврат"
        }
    }
    
//    override var title: String {
//        switch (isNew, isDebt, isLoan, isReturn) {
//        case   (true,  true,   false,  false):  return "Новый долг"
//        case   (true,  false,  true,   false):  return "Новый займ"
//        case   (true,  false,  false,  false):  return "Новый перевод"
//        case   (true,  false,  false,  true):   return "Новый возврат"
//        case   (false, true,   false,  false):  return "Изменить долг"
//        case   (false, false,  true,   false):  return "Изменить займ"
//        case   (false, false,  false,  false):  return "Изменить перевод"
//        case   (false, false,  false,  true):   return "Изменить возврат"
//        default: return "Новый перевод"
//        }
//    }
    
    override var removeTitle: String? { return isNew ? nil : "Удалить перевод" }
    
    override var startableTitle: String? { return "Кошелек снятия" }
    
    override var completableTitle: String? { return "Кошелек пополнения" }
        
    override var startableIconDefaultImageName: String { return IconCategory.expenseSource.defaultIconName }
    
    override var completableIconDefaultImageName: String { return IconCategory.expenseSource.defaultIconName }
    
    init(fundsMovesCoordinator: FundsMovesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         exchangeRatesCoordinator: ExchangeRatesCoordinatorProtocol,
         currencyConverter: CurrencyConverterProtocol) {
        self.fundsMovesCoordinator = fundsMovesCoordinator
        self.accountCoordinator = accountCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        super.init(exchangeRatesCoordinator: exchangeRatesCoordinator, currencyConverter: currencyConverter)
    }
    
    func set(fundsMoveId: Int) {
        transactionableId = fundsMoveId
    }
    
    func set(fundsMove: FundsMove) {
        self.fundsMove = fundsMove
        self.comment = fundsMove.comment
        self.gotAt = fundsMove.gotAt
//        self.whom = fundsMove.whom
//        self.borrowedTill = fundsMove.borrowedTill
        if let borrow = fundsMove.returningBorrow {
            self.borrow = BorrowViewModel(borrow: borrow)
        }
        self.startable = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceFrom)
        self.completable = ExpenseSourceViewModel(expenseSource: fundsMove.expenseSourceTo)
        self.amount = fundsMove.amountCents.moneyDecimalString(with: startableCurrency)
        self.convertedAmount = fundsMove.convertedAmountCents.moneyDecimalString(with: completableCurrency)
    }
    
    func set(startable: ExpenseSourceViewModel?, completable: ExpenseSourceViewModel?, borrow: BorrowViewModel?) {
        self.startable = startable
        self.completable = completable
        self.borrow = borrow
        func amountDebt(expenseSource: ExpenseSourceViewModel?) -> String? {
            guard   let borrow = borrow,
                    expenseSource?.currency.code == borrow.currency.code else {
                return nil
            }
            return borrow.amountLeft
        }
        self.amount = amountDebt(expenseSource: startable)
        self.convertedAmount = amountDebt(expenseSource: completable)
    }
    
//    func set(startable: ExpenseSourceViewModel, completable: ExpenseSourceViewModel, debtTransaction: FundsMoveViewModel?) {
//        self.startable = startable
//        self.completable = completable
//        self.debtTransaction = debtTransaction
//        func amountDebt() -> String? {
//            if let debtTransaction = debtTransaction {
//                if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id == startable.id {
//                    return debtTransaction.debtAmountLeft
//                }
//                if !needCurrencyExchange && debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable.id {
//                    return debtTransaction.loanAmountLeft
//                }
//            }
//            return nil
//        }
//
//        func convertedAmountDebt() -> String? {
//            if let debtTransaction = debtTransaction {
//                if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id == completable.id {
//                    return debtTransaction.loanAmountLeft
//                }
//            }
//            return nil
//        }
//
//        self.amount = amountDebt()
//        self.convertedAmount = convertedAmountDebt()
//    }
    
    override func loadData() -> Promise<Void> {
        return  firstly {
                    loadExpenseSources()
                }.then { _ in
                    return self.isNew ? self.loadExchangeRate() : self.loadTransaction()
                }.asVoid()
    }
    
    override func loadTransactionPromise(transactionableId: Int) -> Promise<Void> {
        return  firstly {
                    fundsMovesCoordinator.show(by: transactionableId)
                }.get { fundsMove in
                    self.set(fundsMove: fundsMove)
                }.asVoid()
    }
    
    func loadExpenseSources() -> Promise<Void> {
        guard isReturn, isNew else { return Promise.value(()) }
        return  firstly {
                    loadExpenseSourcesFromBorrowingTransaction()
                }.then {
                    self.loadDefaultDebtExpenseSourceIfNeeded()
                }
    }
    
    func loadExpenseSourcesFromBorrowingTransaction() -> Promise<Void> {
        return  firstly {
                    loadBorrowingTransaction()
                }.get { borrowingTransaction in
                    self.setExpenseSourcesFrom(borrowingTransaction: borrowingTransaction)
                }.asVoid()
    }
    
    func loadBorrowingTransaction() -> Promise<FundsMove?> {
        guard   let borrow = borrow,
            let borrowingTransactionId = borrow.borrow.borrowingTransactionId else { return Promise.value(nil) }
        return fundsMovesCoordinator.show(by: borrowingTransactionId).map { $0 }
    }
    
    func setExpenseSourcesFrom(borrowingTransaction: FundsMove?) -> Void {
        guard let borrowingTransaction = borrowingTransaction else { return }
        
        let borrowingTransactionExpenseSourceTo = ExpenseSourceViewModel(expenseSource: borrowingTransaction.expenseSourceTo)
        let borrowingTransactionExpenseSourceFrom = ExpenseSourceViewModel(expenseSource: borrowingTransaction.expenseSourceFrom)
        
        if !borrowingTransactionExpenseSourceTo.isDeleted {
            startable = borrowingTransactionExpenseSourceTo
        }
        if !borrowingTransactionExpenseSourceFrom.isDeleted {
            completable = borrowingTransactionExpenseSourceFrom
        }
    }
    
    func loadDefaultDebtExpenseSourceIfNeeded() -> Promise<Void> {
        guard let borrow = borrow else { return Promise.value(()) }
        let shouldLoadDefaultStartable = borrow.isDebt && startable == nil
        let shouldLoadDefaultCompletable = borrow.isLoan && completable == nil
        guard shouldLoadDefaultStartable || shouldLoadDefaultCompletable else { return Promise.value(()) }
        return  firstly {
                    expenseSourcesCoordinator.first(accountType: .debt, currency: borrow.currency.code)
                }.get { expenseSource in
                    let debtExpenseSource = ExpenseSourceViewModel(expenseSource: expenseSource)
                    if shouldLoadDefaultStartable {
                        self.startable = debtExpenseSource
                    }
                    if shouldLoadDefaultCompletable {
                        self.completable = debtExpenseSource
                    }
                }.asVoid()
    }
    
    func removeFundsMove() -> Promise<Void> {
        guard let fundsMoveId = fundsMove?.id else {
            return Promise(error: FundsMoveUpdatingError.updatingFundsMoveIsNotSpecified)
        }
        return fundsMovesCoordinator.destroy(by: fundsMoveId)
    }
    
    override func create() -> Promise<Void> {
//        if let debtTransaction = debtTransaction {
//            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
//                return Promise(error: FundsMoveCreationError.debtDestinationIsNotEqualToReturnSource)
//            }
//            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
//                return Promise(error: FundsMoveCreationError.loanSourceIsNotEqualToReturnDestination)
//            }
//        }
        return fundsMovesCoordinator.create(with: creationForm()).asVoid()
    }
    
    override func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    override func update() -> Promise<Void> {
//        if let debtTransaction = debtTransaction {
//            if debtTransaction.isDebt && debtTransaction.expenseSourceTo.id != startable?.id {
//                return Promise(error: FundsMoveUpdatingError.debtDestinationIsNotEqualToReturnSource)
//            }
//            if debtTransaction.isLoan && debtTransaction.expenseSourceFrom.id != completable?.id {
//                return Promise(error: FundsMoveUpdatingError.loanSourceIsNotEqualToReturnDestination)
//            }
//        }
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
//                                     whom: whom,
//                                     borrowedTill: borrowedTill,
                                     returningBorrowId: borrow?.id)
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
                                     comment: comment)
//                                     whom: whom,
//                                     borrowedTill: borrowedTill)
    }
}
