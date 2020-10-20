//
//  IncomeSourceEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum IncomeSourceUpdatingError : Error {
    case updatingIncomeSourceIsNotSpecified
}

class IncomeSourceEditViewModel : TransactionableExamplesDependantProtocol {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    private let accountCoordinator: AccountCoordinatorProtocol
    var transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol
    
    private var incomeSource: IncomeSource? = nil
    
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil
    var monthlyPlanned: String?
    var description: String?
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    // Computed
    
    var isNew: Bool {
        return incomeSource == nil
    }
    
    var defaultIconName: String {
        return TransactionableType.incomeSource.defaultIconName
    }
    
    var selectedCurrencyName: String? {
        return selectedCurrency?.translatedName
    }
    
    var selectedCurrencyCode: String? {
        return selectedCurrency?.code
    }
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet
            ? NSLocalizedString("Изменить напоминание", comment: "Изменить напоминание")
            : NSLocalizedString("Установить напоминание", comment: "Установить напоминание")
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
    
    // Permissions
    
    var canChangeCurrency: Bool {
        return isNew
    }
    
    var canChangeMonthlyPlanned: Bool {
        return isNew || incomeSource?.activeId == nil
    }
    
    // Visibility
    
    var reminderHidden: Bool {
        return !isNew
    }
    
    var removeButtonHidden: Bool {        
        return isNew || incomeSource!.isChild
    }
    
    var numberOfUnusedExamples: Int = 0
    var basketType: BasketType = .joy
    var example: TransactionableExampleViewModel? = nil
    var transactionableType: TransactionableType {
        return .incomeSource
    }
    
    init(incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         transactionableExamplesCoordinator: TransactionableExamplesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        self.accountCoordinator = accountCoordinator
        self.transactionableExamplesCoordinator = transactionableExamplesCoordinator
    }
    
    func loadData() -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadExamples())
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func set(incomeSource: IncomeSource) {
        self.incomeSource = incomeSource
        selectedIconURL = incomeSource.iconURL
        reminderViewModel = ReminderViewModel(reminder: incomeSource.reminder)
        selectedCurrency = incomeSource.currency
        name = incomeSource.name
        description = incomeSource.description
        monthlyPlanned = incomeSource.monthlyPlannedCents?.moneyDecimalString(with: incomeSource.currency)
    }
    
    func set(example: TransactionableExampleViewModel) {
        self.example = example
        selectedIconURL = example.iconURL
        name = example.name
        description = example.description
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
    
    func removeIncomeSource(deleteTransactions: Bool) -> Promise<Void> {
        guard let incomeSourceId = incomeSource?.id else {
            return Promise(error: IncomeSourceUpdatingError.updatingIncomeSourceIsNotSpecified)
        }
        return incomeSourcesCoordinator.destroy(by: incomeSourceId, deleteTransactions: deleteTransactions)
    }
}

// Creation
extension IncomeSourceEditViewModel {
    private func create() -> Promise<Void> {
        return incomeSourcesCoordinator.create(with: creationForm()).asVoid()
    }
    
    private func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> IncomeSourceCreationForm {        
        return IncomeSourceCreationForm( userId: accountCoordinator.currentSession?.userId,
                                         iconURL: selectedIconURL,
                                         name: name,
                                         currency: selectedCurrencyCode,
                                         monthlyPlannedCents: monthlyPlanned?.intMoney(with: selectedCurrency),
                                         description: description,
                                         prototypeKey: example?.prototypeKey,
                                         reminderAttributes: reminderViewModel.reminderAttributes)
    }
}

// Updating
extension IncomeSourceEditViewModel {
    private func update() -> Promise<Void> {
        return incomeSourcesCoordinator.update(with: updatingForm())
    }
    
    private func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> IncomeSourceUpdatingForm {
        return IncomeSourceUpdatingForm(id: incomeSource?.id,
                                        iconURL: selectedIconURL,
                                        name: name,
                                        monthlyPlannedCents: monthlyPlanned?.intMoney(with: selectedCurrency),
                                        description: description,
                                        reminderAttributes: reminderViewModel.reminderAttributes)
    }
}
