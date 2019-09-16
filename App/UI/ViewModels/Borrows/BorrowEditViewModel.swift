//
//  BorrowEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum BorrowError : Error {
    case borrowIsNotSpecified
}

class BorrowEditViewModel {
    let borrowsCoordinator: BorrowsCoordinatorProtocol
    let accountCoordinator: AccountCoordinatorProtocol
    let fundsMoveCoordinator: FundsMovesCoordinatorProtocol
    let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    private var borrow: Borrow? = nil
    
    var isNew: Bool { return borrowId == nil }
    
    var hasComment: Bool {
        guard let comment = comment else { return false }
        return !comment.isEmpty && !comment.isWhitespace
    }
    
    var expenseSourceSelectionType: ExpenseSourceSelectionType {
        guard let type = type else { return .startable }
        return type == .debt ? .startable : .completable
    }
    
    var borrowId: Int?
    var type: BorrowType? = nil
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil {
        didSet {
            if selectedCurrency?.code != oldValue?.code {
                selectedExpenseSourceFrom = nil
                selectedExpenseSourceTo = nil
            }
        }
    }
    var amount: String? = nil    
    var borrowedAt: Date = Date()
    var payday: Date? = nil
    var comment: String? = nil
    var onBalance: Bool = false
    var selectedExpenseSourceFrom: ExpenseSourceViewModel? = nil
    var selectedExpenseSourceTo: ExpenseSourceViewModel? = nil
    var selectedExpenseSource: ExpenseSourceViewModel? {
        get {
            guard let type = type else { return nil }
            return type == .debt ? selectedExpenseSourceFrom : selectedExpenseSourceTo
        }
        set {
            guard let type = type else { return }
            if type == .debt {
                selectedExpenseSourceFrom = newValue
            }
            else {
                selectedExpenseSourceTo = newValue
            }
        }
    }
    var borrowingTransactionAttributes: BorrowingTransactionNestedAttributes? {
        guard isNew, !onBalance else { return nil }
        return BorrowingTransactionNestedAttributes(expenseSourceFromId: selectedExpenseSourceFrom?.id, expenseSourceToId: selectedExpenseSourceTo?.id)
    }
    var borrowingTransaction: FundsMoveViewModel? = nil
    
    var borrowedAtFormatted: String {
        return borrowedAt.dateString(ofStyle: .short)
    }
    
    var paydayFormatted: String? {
        return payday?.dateString(ofStyle: .short)
    }
    
    var title: String {
        guard let type = type else { return "" }
        switch (isNew, type == .debt, type == .loan) {
        case   (true,  true,   false):      return "Новый долг (вам должны)"
        case   (true,  false,  true):       return "Новый займ (вы должны)"
        case   (false,  true,   false):     return "Долг (вам должны)"
        case   (false,  false,  true):      return "Займ (вы должны)"
        default: return ""
        }
    }
    
    var nameTitle: String? {
        guard let type = type else { return nil }
        return type == .debt ? "Кто вам должен" : "Кому вы должны"
    }
    
    var amountTitle: String? { return "Сумма" }
    
    var borrowedAtTitle: String? {
        guard let type = type else { return nil }
        return type == .debt ? "Когда дали в долг" : "Когда взяли взаймы"
    }
    
    var expenseSourceTitle: String? {
        guard let type = type else { return nil }
        return type == .debt ? "С какого кошелька" : "На какой кошелек"
    }
    
    var returnTitle: String? {
        guard let type = type else { return nil }
        return type == .debt ? "Долг вернули" : "Вернуть займ"
    }
    
    var removeTitle: String? {
        guard let type = type else { return nil }
        return type == .debt ? "Удалить долг" : "Удалить займ"
    }
    
    var removeQuestion: String {
        guard let type = type else { return "Удалить?" }
        return type == .debt ? "Удалить долг?" : "Удалить займ?"
    }
    
    var iconDefaultImageName: String { return IconCategory.expenseSourceDebt.defaultIconName }
    var expenseSourceIconURL: URL? { return selectedExpenseSource?.iconURL }
    var expenseSourceIconDefaultImageName: String { return IconCategory.expenseSource.defaultIconName }
    var expenseSourceName: String? { return selectedExpenseSource?.name }
    var expenseSourceAmount: String? { return selectedExpenseSource?.amount }
    var expenseSourceCurrency: Currency? { return selectedExpenseSource?.currency }
    var expenseSourceCurrencyCode: String? { return expenseSourceCurrency?.code }
    
    // Visibility
    var removeButtonHidden: Bool { return isNew }
    
    var returnButtonHidden: Bool {
        guard !isNew, let borrow = borrow else { return true }
        return borrow.isReturned
    }
    
    var onBalanceSwitchHidden: Bool {
        return !isNew || selectedCurrency == nil
    }
    
    var expenseSourceFieldHidden: Bool {
        return !isNew || onBalance || selectedCurrency == nil
    }
    
    // Permissions
    var canChangeCurrency: Bool { return isNew }
    
    init(borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         fundsMoveCoordinator: FundsMovesCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.borrowsCoordinator = borrowsCoordinator
        self.accountCoordinator = accountCoordinator
        self.fundsMoveCoordinator = fundsMoveCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
    
    func set(type: BorrowType, expenseSourceFrom: ExpenseSourceViewModel?, expenseSourceTo: ExpenseSourceViewModel?) {
        self.type = type
        if type == .debt {
            selectedCurrency = expenseSourceTo?.currency
        } else {
            selectedCurrency = expenseSourceFrom?.currency
        }
        self.selectedExpenseSourceFrom = expenseSourceFrom
        self.selectedExpenseSourceTo = expenseSourceTo        
    }
    
    func set(borrowId: Int, type: BorrowType) {
        self.borrowId = borrowId
        self.type = type
    }
    
    private func set(borrow: Borrow) {
        self.borrow = borrow
        self.borrowId = borrow.id
        self.type = borrow.type
        self.selectedIconURL = borrow.iconURL
        self.name = borrow.name
        self.selectedCurrency = borrow.currency
        self.amount = borrow.amountCents.moneyDecimalString(with: borrow.currency)
        self.borrowedAt = borrow.borrowedAt
        self.payday = borrow.payday
        self.comment = borrow.comment
        self.onBalance = true
    }
    
    func loadData() -> Promise<Void> {
        if isNew {
            return loadDefaults()
        }
        return  firstly {
                    loadBorrow()
                }.then { borrow in
                    self.loadBorrowingTransaction(id: borrow.borrowingTransactionId)
                }
    }
    
    func loadDefaults() -> Promise<Void> {
        guard selectedCurrency == nil else { return Promise.value(()) }
        return  firstly {
                    loadDefaultCurrency()
                }.then {
                    self.loadDefaultExpenseSource()
                }
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                    if self.isNew {
                        if self.amount == nil {
                            self.amount = 0.moneyDecimalString(with: self.selectedCurrency)
                        }
                    }
                }
    }
    
    private func loadBorrowBy(id: Int, type: BorrowType) -> Promise<Borrow> {
        if type == .debt {
            return borrowsCoordinator.showDebt(by: id)
        }
        return borrowsCoordinator.showLoan(by: id)
    }
    
    private func loadBorrow() -> Promise<Borrow> {
        guard let borrowId = borrowId, let type = type else {
            return Promise(error: BorrowError.borrowIsNotSpecified)
        }
        return  firstly {
                    loadBorrowBy(id: borrowId, type: type)
                }.get { borrow in
                    self.set(borrow: borrow)
                }
    }
    
    private func loadBorrowingTransaction(id: Int?) -> Promise<Void> {
        guard let id = id else {
            return Promise.value(())
        }
        return  firstly {
                    fundsMoveCoordinator.show(by: id)
                }.get { fundsMove in
                    self.borrowingTransaction = FundsMoveViewModel(fundsMove: fundsMove)
                }.asVoid()
    }
    
    func loadDefaultExpenseSource() -> Promise<Void> {
        guard let currency = selectedCurrency?.code, selectedExpenseSource == nil else {
            return Promise.value(())
        }
        return  firstly {
                    expenseSourcesCoordinator.first(accountType: .usual, currency: currency)
                }.get { expenseSource in
                    self.selectedExpenseSource = ExpenseSourceViewModel(expenseSource: expenseSource)
                }.asVoid()
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
    
    func removeBorrow(deleteTransactions: Bool) -> Promise<Void> {
        guard let borrowId = borrowId, let type = type else {
            return Promise(error: BorrowError.borrowIsNotSpecified)
        }
        if type == .debt {
            return borrowsCoordinator.destroyDebt(by: borrowId, deleteTransactions: deleteTransactions)
        }
        return borrowsCoordinator.destroyLoan(by: borrowId, deleteTransactions: deleteTransactions)
    }
    
    func asReturningBorrow() -> BorrowViewModel? {
        guard let borrow = borrow else { return nil }
        return BorrowViewModel(borrow: borrow)
    }
}

// Creation
extension BorrowEditViewModel {
    func create() -> Promise<Void> {
        guard let type = type else {
            return Promise(error: BorrowError.borrowIsNotSpecified)
        }
        if type == .debt {
            return borrowsCoordinator.createDebt(with: creationForm()).asVoid()
        }
        return borrowsCoordinator.createLoan(with: creationForm()).asVoid()
    }
    
    func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> BorrowCreationForm {
        return BorrowCreationForm(userId: accountCoordinator.currentSession?.userId,
                                 type: type,
                                 name: name,
                                 iconURL: selectedIconURL,
                                 amountCents: amount?.intMoney(with: selectedCurrency),
                                 amountCurrency: selectedCurrency?.code,
                                 borrowedAt: borrowedAt,
                                 payday: payday,
                                 comment: comment,
                                 alreadyOnBalance: onBalance,
                                 borrowingTransactionAttributes: borrowingTransactionAttributes)
    }
}

// Updating
extension BorrowEditViewModel {
    func update() -> Promise<Void> {
        guard let type = type else {
            return Promise(error: BorrowError.borrowIsNotSpecified)
        }
        if type == .debt {
            return borrowsCoordinator.updateDebt(with: updatingForm())
        }
        return borrowsCoordinator.updateLoan(with: updatingForm())
    }
    
    func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> BorrowUpdatingForm {
        return BorrowUpdatingForm(id: borrow?.id,
                                 name: name,
                                 iconURL: selectedIconURL,
                                 amountCents: amount?.intMoney(with: selectedCurrency),
                                 borrowedAt: borrowedAt,
                                 payday: payday,
                                 comment: comment)
    }
}
