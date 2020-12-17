//
//  BorrowEditViewModel.swift
//  Capitalist
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
    let transactionsCoordinator: TransactionsCoordinatorProtocol
    let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    private var borrow: Borrow? = nil
    
    var isNew: Bool { return borrowId == nil }
    
    var hasComment: Bool {
        guard let comment = comment else { return false }
        return !comment.isEmpty && !comment.isWhitespace
    }
    
    var expenseSourceSelectionType: TransactionPart {
        guard let type = type else { return .source }
        return type == .debt ? .source : .destination
    }
    
    var borrowId: Int?
    var type: BorrowType? = nil
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil {
        didSet {
            if selectedCurrency?.code != oldValue?.code {
                selectedSource = nil
                selectedDestination = nil
            }
        }
    }
    var amount: String? = nil    
    var borrowedAt: Date = Date()
    var payday: Date? = nil
    var comment: String? = nil
    var shouldRecordOnBalance: Bool = false
    var selectedSource: TransactionSource? = nil
    var selectedDestination: TransactionDestination? = nil
    var selectedExpenseSource: ExpenseSourceViewModel? {
        get {
            guard let type = type else { return nil }
            return (type == .debt ? selectedSource : selectedDestination) as? ExpenseSourceViewModel
        }
        set {
            guard let type = type else { return }
            if type == .debt {
                selectedSource = newValue
            }
            else {
                selectedDestination = newValue
            }
        }
    }
    var borrowingTransactionAttributes: BorrowingTransactionNestedAttributes? {
        guard isNew, let type = type else { return nil }
        
        if shouldRecordOnBalance {
            return BorrowingTransactionNestedAttributes(id: borrowingTransaction?.id,
                                                        sourceId: selectedSource?.id,
                                                        sourceType: selectedSource?.type,
                                                        destinationId: selectedDestination?.id,
                                                        destinationType: selectedDestination?.type)
        }
        
        if type == .loan && !shouldRecordOnBalance {
            return BorrowingTransactionNestedAttributes(id: nil,
                                                        sourceId: nil,
                                                        sourceType: .incomeSource,
                                                        destinationId: nil,
                                                        destinationType: .expenseSource)
        }
        
        if type == .debt && !shouldRecordOnBalance {
            return BorrowingTransactionNestedAttributes(id: nil,
                                                        sourceId: nil,
                                                        sourceType: .expenseSource,
                                                        destinationId: nil,
                                                        destinationType: .expenseCategory)
        }
        
        return nil
    }
    var borrowingTransaction: TransactionViewModel? = nil
    
    var borrowedAtFormatted: String {
        return borrowedAt.dateString(ofStyle: .short)
    }
    
    var paydayFormatted: String? {
        return payday?.dateString(ofStyle: .short)
    }
    
    var title: String {
        guard let type = type else { return "" }
        switch (isNew, type == .debt, type == .loan) {
        case   (true,  true,   false):      return NSLocalizedString("Новый долг (вам должны)", comment: "Новый долг (вам должны)")
        case   (true,  false,  true):       return NSLocalizedString("Новый займ (вы должны)", comment: "Новый займ (вы должны)")
        case   (false,  true,   false):     return NSLocalizedString("Долг (вам должны)", comment: "Долг (вам должны)")
        case   (false,  false,  true):      return NSLocalizedString("Займ (вы должны)", comment: "Займ (вы должны)")
        default: return ""
        }
    }
    
    var nameTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Кто вам должен", comment: "Кто вам должен")
            : NSLocalizedString("Кому вы должны", comment: "Кому вы должны")
    }
    
    var amountTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Сумма долга", comment: "Сумма долга")
            : NSLocalizedString("Сумма займа", comment: "Сумма займа")
    }
    
    var shouldRecordOnBalanceTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Списать сумму с кошелька", comment: "Списать сумму с кошелька")
            : NSLocalizedString("Зачислить сумму на кошелек", comment: "Зачислить сумму на кошелек")
    }
    
    var borrowedAtTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Когда дали в долг", comment: "Когда дали в долг")
            : NSLocalizedString("Когда взяли взаймы", comment: "Когда взяли взаймы")
    }
    
    var expenseSourceTitle: String? {
        return NSLocalizedString("Кошелек", comment: "Кошелек")
    }
    
    var returnTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Долг вернули", comment: "Долг вернули")
            : NSLocalizedString("Вернуть займ", comment: "Вернуть займ")
    }
    
    var removeTitle: String? {
        guard let type = type else { return nil }
        return type == .debt
            ? NSLocalizedString("Удалить долг", comment: "Удалить долг")
            : NSLocalizedString("Удалить займ", comment: "Удалить займ")
    }
    
    var removeQuestion: String {
        guard let type = type else { return NSLocalizedString("Удалить?", comment: "Удалить?") }
        return type == .debt
            ? NSLocalizedString("Удалить долг?", comment: "Удалить долг?")
            : NSLocalizedString("Удалить займ?", comment: "Удалить займ?")
    }
        
    var iconDefaultImageName: String { return "borrow-default-icon" }
    var expenseSourceIconURL: URL? { return selectedExpenseSource?.iconURL }
    var expenseSourceIconDefaultImageName: String { return TransactionableType.expenseSource.defaultIconName }
    var expenseSourceName: String? { return selectedExpenseSource?.name }
    var expenseSourceAmount: String? { return selectedExpenseSource?.amount }
    var expenseSourceCurrency: Currency? { return selectedExpenseSource?.currency }
    var expenseSourceCurrencyCode: String? { return expenseSourceCurrency?.code }
    
    // Visibility
    var removeButtonHidden: Bool { return isNew || isBorrowingTransactionRemote }
    
    var returnButtonHidden: Bool {
        guard !isNew, let borrow = borrow else { return true }
        return borrow.isReturned
    }
    
    var onBalanceSwitchHidden: Bool {
        return !isNew || selectedCurrency == nil || borrowingTransaction != nil
    }
    
    var expenseSourceFieldHidden: Bool {
        return !isNew || !shouldRecordOnBalance || selectedCurrency == nil
    }
    
    // Permissions
    var canChangeCurrency: Bool { return isNew && borrowingTransaction == nil }
    
    var canChangeAmount: Bool { return (isNew && borrowingTransaction == nil) || (!isNew && !isBorrowingTransactionRemote) }
    
    var canChangeExpenseSource: Bool { return isNew && borrowingTransaction == nil }
    
    var canChangeBorrowedAt: Bool { return !isNew || (isNew && borrowingTransaction == nil) }
    
    var shouldSaveBorrowingTransaction: Bool {
        return isNew && borrowingTransaction != nil
    }
    
    var isBorrowingTransactionRemote: Bool {
        return borrowingTransaction?.isRemote ?? false
    }
    
    init(borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         transactionsCoordinator: TransactionsCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.borrowsCoordinator = borrowsCoordinator
        self.accountCoordinator = accountCoordinator
        self.transactionsCoordinator = transactionsCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
    }
    
    func set(type: BorrowType,
             source: TransactionSource?,
             destination: TransactionDestination?,
             borrowingTransaction: Transaction?) {
        self.type = type
        selectedCurrency = type == .debt ? source?.currency : destination?.currency
        selectedSource = source
        selectedDestination = destination
        if let borrowingTransaction = borrowingTransaction {
            self.borrowingTransaction = TransactionViewModel(transaction: borrowingTransaction)
        }        
        let amountCents = type == .debt ? borrowingTransaction?.amountCents : borrowingTransaction?.convertedAmountCents
        amount = amountCents?.moneyDecimalString(with: selectedCurrency)
        self.name = borrowingTransaction?.comment
        self.borrowedAt = borrowingTransaction?.gotAt ?? Date()        
        shouldRecordOnBalance = source != nil && destination != nil
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
        self.shouldRecordOnBalance = false
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
                }
    }
    
    func loadDefaultExpenseSource() -> Promise<Void> {
        guard let currency = selectedCurrency?.code, selectedExpenseSource == nil else {
            return Promise.value(())
        }
        return  firstly {
                    expenseSourcesCoordinator.first(currency: currency, isVirtual: false)
                }.get { expenseSource in
                    self.selectedExpenseSource = ExpenseSourceViewModel(expenseSource: expenseSource)
                }.asVoid()
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
    
    private func loadBorrowBy(id: Int, type: BorrowType) -> Promise<Borrow> {
        if type == .debt {
            return borrowsCoordinator.showDebt(by: id)
        }
        return borrowsCoordinator.showLoan(by: id)
    }

    private func loadBorrowingTransaction(id: Int?) -> Promise<Void> {
        guard let id = id else {
            return Promise.value(())
        }
        return  firstly {
                    transactionsCoordinator.show(by: id)
                }.get { transaction in
                    self.borrowingTransaction = TransactionViewModel(transaction: transaction)
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
        guard
            let type = type
        else {
            return Promise(error: BorrowError.borrowIsNotSpecified)
        }
        return
            firstly {
                saveBorrowingTransaction()
            }.then { () -> Promise<Void> in
                if type == .debt {
                    return self.borrowsCoordinator.createDebt(with: self.creationForm()).asVoid()
                }
                return self.borrowsCoordinator.createLoan(with: self.creationForm()).asVoid()
            }.asVoid()
        
    }
    
    func saveBorrowingTransaction() -> Promise<Void> {
        guard
            shouldSaveBorrowingTransaction,
            let borrowingTransaction = borrowingTransaction
        else {
            return Promise.value(())
        }
        return transactionsCoordinator.update(with: TransactionUpdatingForm(id: borrowingTransaction.id,
                                                                            sourceId: selectedSource?.id,
                                                                            sourceType: selectedSource?.type,
                                                                            destinationId: selectedDestination?.id,
                                                                            destinationType: selectedDestination?.type,
                                                                            amountCents: borrowingTransaction.amountCents,
                                                                            amountCurrency: borrowingTransaction.currency.code,
                                                                            convertedAmountCents: borrowingTransaction.convertedAmountCents,
                                                                            convertedAmountCurrency: borrowingTransaction.convertedCurrency.code,
                                                                            gotAt: borrowingTransaction.gotAt,
                                                                            comment: borrowingTransaction.comment,
                                                                            returningBorrowId: borrowingTransaction.transaction.returningBorrow?.id,
                                                                            isBuyingAsset: borrowingTransaction.transaction.isBuyingAsset,
                                                                            updateSimilarTransactions: false))
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
                                 alreadyOnBalance: !shouldRecordOnBalance,
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
                                 comment: comment,
                                 borrowingTransactionAttributes: borrowingTransactionAttributes)
    }
}
