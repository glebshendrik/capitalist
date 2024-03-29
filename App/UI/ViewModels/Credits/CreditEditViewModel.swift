//
//  CreditEditViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum CreditError : Error {
    case creditIsNotSpecified
}

class CreditEditViewModel {
    let creditsCoordinator: CreditsCoordinatorProtocol
    let accountCoordinator: AccountCoordinatorProtocol
    let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    let transactionsCoordinator: TransactionsCoordinatorProtocol
    
    private var credit: Credit? = nil
    
    var isNew: Bool { return creditId == nil }
    
    var creditId: Int?
    var creditTypes: [CreditTypeViewModel] = []
    var selectedCreditType: CreditTypeViewModel? = nil {
        didSet {
            if selectedCreditType == nil || !selectedCreditType!.hasMonthlyPayments {
                monthlyPayment = nil
            }
            period = selectedCreditType?.defaultValue
        }
    }
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil { didSet { updateMonthlyPayment() } }
    var amount: String? = nil
    var returnAmount: String? = nil { didSet { updateMonthlyPayment() } }
    var alreadyPaid: String? = nil { didSet { updateMonthlyPayment() } }
    var monthlyPayment: String? = nil
    var monthlyPaymentCalculated: String? = nil
    var gotAt: Date = Date()
    var period: Int? = nil { didSet { updateMonthlyPayment() } }
    var expenseCategoryId: Int? = nil
    
    var shouldRecordOnBalance: Bool = false
    var selectedDestination: ExpenseSourceViewModel? = nil
    var creditingTransactionAttributes: CreditingTransactionNestedAttributes? {
        guard
            isNew
        else {
            return nil            
        }
        return CreditingTransactionNestedAttributes(id: creditingTransaction?.id,
                                                    destinationId: shouldRecordOnBalance ? selectedDestination?.id : nil)
    }
    
    var creditingTransaction: TransactionViewModel? = nil
    
    var monthlyPaymentToSave: String? {
        if let monthlyPayment = monthlyPayment, !monthlyPayment.isEmpty {
            return monthlyPayment
        }
        return monthlyPaymentCalculated
    }
    
    var alreadyPaidToSave: String {
        guard   let alreadyPaid = alreadyPaid,
                !alreadyPaid.isEmpty  else { return "0" }
        return alreadyPaid
    }
    
    var expenseSourceIconURL: URL? { return selectedDestination?.iconURL }
    var expenseSourceIconDefaultImageName: String { return TransactionableType.expenseSource.defaultIconName }
    var expenseSourceName: String? { return selectedDestination?.name }
    var expenseSourceAmount: String? { return selectedDestination?.amount }
    var expenseSourceCurrency: Currency? { return selectedDestination?.currency }
    var expenseSourceCurrencyCode: String? { return expenseSourceCurrency?.code }
    
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet
            ? NSLocalizedString("Изменить напоминание", comment: "Изменить напоминание")
            : NSLocalizedString("Установить напоминание", comment: "Установить напоминание")
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
    
    var gotAtFormatted: String {
        return gotAt.dateString(ofStyle: .short)
    }
        
    var title: String {
        return isNew
            ? NSLocalizedString("Новый кредит", comment: "Новый кредит")
            : NSLocalizedString("Кредит", comment: "Кредит")        
    }
    
    var iconDefaultImageName: String { return "credit-default-icon" }
    
    var minValue: Float {
        return Float(selectedCreditType?.minValue ?? 0)
    }
        
    var maxValue: Float {
        return Float(selectedCreditType?.maxValue ?? 1)
    }
    
    var periodValue: Float {
        return Float(period ?? 0)
    }
    
    // Visibility
    var onBalanceSwitchHidden: Bool {
        return !isNew || selectedCurrency == nil || creditingTransaction != nil
    }
    
    var expenseSourceFieldHidden: Bool {
        return !isNew || !shouldRecordOnBalance || selectedCurrency == nil
    }
    
    var monthlyPaymentFieldHidden: Bool {
        guard let creditType = selectedCreditType else { return true }
        return !creditType.hasMonthlyPayments
    }
    
    var periodFieldHidden: Bool {
        return selectedCreditType == nil
    }
    
    var reminderHidden: Bool {
        return !isNew
    }
    
    var removeButtonHidden: Bool { return isNew || isCreditingTransactionRemote }
        
    // Permissions
    var canChangeCreditType: Bool { return isNew }
    
    var canChangeAlreadyPaid: Bool { return isNew }
    
    var canChangeCurrency: Bool { return isNew && creditingTransaction == nil }
    
    var canChangeAmount: Bool { return (isNew && creditingTransaction == nil) || (!isNew && !isCreditingTransactionRemote) }
    
    var canChangeExpenseSource: Bool { return isNew && creditingTransaction == nil }
    
    var canChangeGotAt: Bool { return !isNew || (isNew && creditingTransaction == nil) }
    
    var shouldSaveCreditingTransaction: Bool {
        return isNew && creditingTransaction != nil
    }
    
    var isCreditingTransactionRemote: Bool {
        return creditingTransaction?.isRemote ?? false
    }
    
    var source: IncomeSourceViewModel? = nil
    
    init(creditsCoordinator: CreditsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol,
         transactionsCoordinator: TransactionsCoordinatorProtocol) {
        self.creditsCoordinator = creditsCoordinator
        self.accountCoordinator = accountCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        self.transactionsCoordinator = transactionsCoordinator
    }
    
    func set(source: IncomeSourceViewModel?,
             destination: ExpenseSourceViewModel?,
             creditingTransaction: Transaction?) {
        self.source = source
        self.selectedDestination = destination
        selectedCurrency = destination?.currency
        if let creditingTransaction = creditingTransaction {
            self.creditingTransaction = TransactionViewModel(transaction: creditingTransaction)
        }
        amount = creditingTransaction?.convertedAmountCents.moneyDecimalString(with: selectedCurrency)
        self.gotAt = creditingTransaction?.gotAt ?? Date()
        shouldRecordOnBalance = destination != nil
    }
    
    func set(creditId: Int) {
        self.creditId = creditId
    }
    
    private func set(credit: Credit) {
        self.credit = credit
        self.creditId = credit.id
        self.selectedCreditType = CreditTypeViewModel(creditType: credit.creditType)
        self.selectedIconURL = credit.iconURL
        self.name = credit.name
        self.selectedCurrency = credit.currency
        self.amount = credit.amountCents?.moneyDecimalString(with: credit.currency)
        self.returnAmount = credit.returnAmountCents.moneyDecimalString(with: credit.currency)
        self.alreadyPaid = credit.paidAmountCents.moneyDecimalString(with: credit.currency)
        self.monthlyPayment = credit.monthlyPaymentCents?.moneyDecimalString(with: credit.currency)
        self.gotAt = credit.gotAt
        self.period = credit.period
        self.expenseCategoryId = credit.expenseCategoryId
        self.reminderViewModel = ReminderViewModel(reminder: credit.reminder)
    }
    
    func loadData() -> Promise<Void> {
        if isNew {
            return loadDefaults()
        }
        return
            firstly {
                loadCredit()
            }.then { credit in
                self.loadCreditingTransaction(id: credit.creditingTransactionId)
            }
    }
    
    func loadDefaults() -> Promise<Void> {
        return when(fulfilled: loadCurrencyDefaults(), loadCreditTypes()).asVoid()
    }
    
    func loadCurrencyDefaults() -> Promise<Void> {
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
        guard let currency = selectedCurrency?.code, selectedDestination == nil else {
            return Promise.value(())
        }
        return  firstly {
                    expenseSourcesCoordinator.first(currency: currency, isVirtual: false)
                }.get { expenseSource in
                    self.selectedDestination = ExpenseSourceViewModel(expenseSource: expenseSource)
                }.asVoid()
    }
    
    private func loadCreditingTransaction(id: Int?) -> Promise<Void> {
        guard let id = id else {
            return Promise.value(())
        }
        return
            firstly {
                transactionsCoordinator.show(by: id)
            }.get { transaction in
                self.creditingTransaction = TransactionViewModel(transaction: transaction)
            }.asVoid()
    }
    
    private func loadCreditTypes() -> Promise<[CreditType]> {
        return  firstly {
                    creditsCoordinator.indexCreditTypes()
                }.get { creditTypes in
                    self.creditTypes = creditTypes.map { CreditTypeViewModel(creditType: $0) }
                    self.selectedCreditType = self.creditTypes.first { $0.isDefault }
                }
    }
        
    private func loadCredit() -> Promise<Credit> {
        guard let creditId = creditId else {
            return Promise(error: CreditError.creditIsNotSpecified)
        }
        return  firstly {
                    creditsCoordinator.showCredit(by: creditId)
                }.get { credit in
                    self.set(credit: credit)
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
    
    func removeCredit(deleteTransactions: Bool) -> Promise<Void> {
        guard let creditId = creditId else {
            return Promise(error: CreditError.creditIsNotSpecified)
        }
        return creditsCoordinator.destroyCredit(by: creditId, deleteTransactions: deleteTransactions)
    }
    
    func updateMonthlyPayment() {
        guard isNew else { return }
        guard   let creditType = selectedCreditType,
                let months = periodInMonths(period: period, unit: creditType.periodUnit),
                let currency = selectedCurrency,
                let returnAmountCents = returnAmount?.intMoney(with: selectedCurrency)?.number,
                let alreadyPaidCents = alreadyPaidToSave.intMoney(with: selectedCurrency)?.number else {
                    
                    monthlyPaymentCalculated = nil
                    return
        }        
        
        let monthlyPaymentCents = returnAmountCents.subtracting(alreadyPaidCents).dividing(by: NSDecimalNumber(integerLiteral: months))
        monthlyPaymentCalculated = monthlyPaymentCents.moneyDecimalString(with: currency)
    }
    
    func periodInMonths(period: Int?, unit: PeriodUnit) -> Int? {
        guard let period = period else { return nil }
        switch unit {
        case .days:
            return nil
        case .months:
            return period
        case .years:
            return period * 12
        }
    }
}

// Creation
extension CreditEditViewModel {
    func create() -> Promise<Void> {
        return
            firstly {
                saveCreditingTransaction()
            }.then { () -> Promise<Void> in
                return self.creditsCoordinator.createCredit(with: self.creationForm()).asVoid()
            }.asVoid()
    }
    
    func saveCreditingTransaction() -> Promise<Void> {
        guard
            shouldSaveCreditingTransaction,
            let creditingTransaction = creditingTransaction
        else {
            return Promise.value(())
        }
        return transactionsCoordinator.update(with: TransactionUpdatingForm(id: creditingTransaction.id,
                                                                            sourceId: source?.id,
                                                                            sourceType: source?.type,
                                                                            destinationId: selectedDestination?.id,
                                                                            destinationType: selectedDestination?.type,
                                                                            amountCents: creditingTransaction.amountCents,
                                                                            amountCurrency: creditingTransaction.currency.code,
                                                                            convertedAmountCents: creditingTransaction.convertedAmountCents,
                                                                            convertedAmountCurrency: creditingTransaction.convertedCurrency.code,
                                                                            gotAt: creditingTransaction.gotAt,
                                                                            comment: creditingTransaction.comment,
                                                                            returningBorrowId: creditingTransaction.transaction.returningBorrow?.id,
                                                                            isBuyingAsset: creditingTransaction.transaction.isBuyingAsset,
                                                                            updateSimilarTransactions: false))
    }
    
    func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> CreditCreationForm {        
        return CreditCreationForm(userId: accountCoordinator.currentSession?.userId,
                                  creditTypeId: selectedCreditType?.id,
                                  name: name,
                                  iconURL: selectedIconURL,
                                  currency: selectedCurrency?.code,
                                  amountCents: amount?.intMoney(with: selectedCurrency),
                                  returnAmountCents: returnAmount?.intMoney(with: selectedCurrency),
                                  alreadyPaidCents: alreadyPaidToSave.intMoney(with: selectedCurrency),
                                  monthlyPaymentCents: monthlyPaymentToSave?.intMoney(with: selectedCurrency),
                                  gotAt: gotAt,
                                  period: period,
                                  reminderAttributes: reminderViewModel.reminderAttributes,
                                  creditingTransactionAttributes: creditingTransactionAttributes)
    }
}

// Updating
extension CreditEditViewModel {
    func update() -> Promise<Void> {
        return creditsCoordinator.updateCredit(with: updatingForm())
    }
    
    func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> CreditUpdatingForm {        
        return CreditUpdatingForm(id: credit?.id,
                                  name: name,
                                  iconURL: selectedIconURL,
                                  amountCents: amount?.intMoney(with: selectedCurrency),
                                  returnAmountCents: returnAmount?.intMoney(with: selectedCurrency),
                                  monthlyPaymentCents: monthlyPaymentToSave?.intMoney(with: selectedCurrency),
                                  gotAt: gotAt,
                                  period: period,
                                  reminderAttributes: reminderViewModel.reminderAttributes,
                                  creditingTransactionAttributes: creditingTransactionAttributes)
    }
}
