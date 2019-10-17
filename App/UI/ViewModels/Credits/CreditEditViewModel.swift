//
//  CreditEditViewModel.swift
//  Three Baskets
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
    var selectedCurrency: Currency? = nil
    var amount: String? = nil
    var alreadyPaid: String? = nil
    var monthlyPayment: String? = nil
    var gotAt: Date = Date()
    var period: Int? = nil
    var expenseCategoryId: Int? = nil
    
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet ? "Изменить напоминание" : "Установить напоминание"
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
    
    var gotAtFormatted: String {
        return gotAt.dateString(ofStyle: .short)
    }
        
    var title: String { return isNew ? "Новый кредит" : "Кредит" }
        
    var iconDefaultImageName: String { return IconCategory.expenseSourceDebt.defaultIconName }
    
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
    var monthlyPaymentFieldHidden: Bool {
        guard let creditType = selectedCreditType else { return true }
        return !creditType.hasMonthlyPayments
    }
    
    var periodFieldHidden: Bool {
        return selectedCreditType == nil
    }
    
    var removeButtonHidden: Bool { return isNew }
        
    // Permissions
    var canChangeCurrency: Bool { return isNew }
    
    var canChangeCreditType: Bool { return isNew }
    
    var canChangeAlreadyPaid: Bool { return isNew }
    
    init(creditsCoordinator: CreditsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.creditsCoordinator = creditsCoordinator
        self.accountCoordinator = accountCoordinator
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
        self.amount = credit.amountCents.moneyDecimalString(with: credit.currency)
        self.alreadyPaid = credit.paidAmountCents.moneyDecimalString(with: credit.currency)
        self.monthlyPayment = credit.monthlyPaymentCents?.moneyDecimalString(with: credit.currency)
        self.gotAt = credit.gotAt
        self.period = credit.period
        self.expenseCategoryId = credit.expenseCategoryId
        self.reminderViewModel = ReminderViewModel(reminder: credit.reminder)
    }
    
    func loadData() -> Promise<Void> {
        return isNew ? loadDefaults() : loadCredit()
    }
    
    func loadDefaults() -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadCreditTypes()).asVoid()
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    private func loadCreditTypes() -> Promise<[CreditType]> {
        return  firstly {
                    creditsCoordinator.indexCreditTypes()
                }.get { creditTypes in
                    self.creditTypes = creditTypes.map { CreditTypeViewModel(creditType: $0) }
                }
    }
        
    private func loadCredit() -> Promise<Void> {
        guard let creditId = creditId else {
            return Promise(error: CreditError.creditIsNotSpecified)
        }
        return  firstly {
                    creditsCoordinator.showCredit(by: creditId)
                }.get { credit in
                    self.set(credit: credit)
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
    
    func removeCredit(deleteTransactions: Bool) -> Promise<Void> {
        guard let creditId = creditId else {
            return Promise(error: CreditError.creditIsNotSpecified)
        }
        return creditsCoordinator.destroyCredit(by: creditId, deleteTransactions: deleteTransactions)
    }
}

// Creation
extension CreditEditViewModel {
    func create() -> Promise<Void> {
        return creditsCoordinator.createCredit(with: creationForm()).asVoid()
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
                                  alreadyPaidCents: alreadyPaid?.intMoney(with: selectedCurrency),
                                  monthlyPaymentCents: monthlyPayment?.intMoney(with: selectedCurrency),
                                  gotAt: gotAt,
                                  period: period,
                                  reminderAttributes: reminderViewModel.reminderAttributes)
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
                                  monthlyPaymentCents: monthlyPayment?.intMoney(with: selectedCurrency),
                                  gotAt: gotAt,
                                  period: period,
                                  reminderAttributes: reminderViewModel.reminderAttributes)
    }
}
