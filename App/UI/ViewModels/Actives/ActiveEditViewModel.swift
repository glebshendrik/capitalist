//
//  ActiveEditViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ActiveError : Error {
    case activeIsNotSpecified
}

class ActiveEditViewModel {
    let activesCoordinator: ActivesCoordinatorProtocol
    let accountCoordinator: AccountCoordinatorProtocol
    
    private var active: Active? = nil
    public private(set) var basketType: BasketType = .safe
    
    var isNew: Bool { return activeId == nil }
    
    var activeId: Int?
    var activeTypes: [ActiveTypeViewModel] = []
    var selectedActiveType: ActiveTypeViewModel? = nil {
        didSet {
            selectedActiveIncomeType = selectedActiveType?.defaultPlannedIncomeType
            isIncomePlanned = selectedActiveType?.isIncomePlannedDefault ?? isIncomePlanned
        }
    }
    var selectedIconURL: URL? = nil
    var name: String? = nil
    var selectedCurrency: Currency? = nil
    var cost: String? = nil
    var costToSave: String {
        guard   let cost = cost,
                !cost.isEmpty  else { return "0" }
        return cost
    }
    var goal: String? = nil
    var alreadyPaid: String? = nil
    var monthlyPayment: String? = nil
    var isIncomePlanned: Bool = true
    var selectedActiveIncomeType: ActiveIncomeType? = nil {
        didSet {
            if selectedActiveIncomeType == nil {
                monthlyPlannedIncome = nil
                annualPercent = nil
            }
        }
    }
    var annualPercent: String? = nil
    var monthlyPlannedIncome: String? = nil
    
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet ? "Изменить напоминание" : "Установить напоминание"
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
            
    var title: String { return isNew ? "Новый актив" : "Актив" }
    
    var costTitle: String { return selectedActiveType?.costTitle ?? "Стоимость актива" }
    
    var monthlyPaymentTitle: String { return selectedActiveType?.monthlyPaymentTitle ?? "Планирую инвестировать в месяц" }
        
    var iconDefaultImageName: String { return basketType.iconCategory.defaultIconName }
        
    // Visibility
    var goalAmountFieldHidden: Bool {
        guard let selectedActiveType = selectedActiveType else { return true }
        return !selectedActiveType.isGoalAmountRequired
    }
    
    var alreadyPaidFieldHidden: Bool {
        return !isNew || (selectedActiveType != nil && selectedActiveType!.onlyBuyingAssets)
    }
    
    var activeIncomeTypeFieldHidden: Bool {
        return !isIncomePlanned
    }
    
    var monthlyPlannedIncomeFieldHidden: Bool {
        guard isIncomePlanned, let selectedActiveIncomeType = selectedActiveIncomeType else { return true }
        return selectedActiveIncomeType != .monthlyIncome
    }
    
    var annualPercentFieldHidden: Bool {
        guard isIncomePlanned, let selectedActiveIncomeType = selectedActiveIncomeType else { return true }
        return selectedActiveIncomeType != .annualPercents
    }
    
    var removeButtonHidden: Bool { return isNew }
        
    // Permissions
    var canChangeCurrency: Bool { return isNew }
    
    var canChangeActiveType: Bool { return isNew }
        
    init(activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
    }
      
    func set(basketType: BasketType) {
        self.basketType = basketType
    }
    
    func set(activeId: Int) {
        self.activeId = activeId
    }
    
    func set(active: Active) {
        self.active = active
        self.activeId = active.id
        self.basketType = active.basketType
        self.selectedActiveType = ActiveTypeViewModel(activeType: active.activeType)
        self.selectedIconURL = active.iconURL
        self.name = active.name
        self.selectedCurrency = active.currency
        self.cost = active.costCents.moneyDecimalString(with: active.currency)
        self.goal = active.goalAmountCents?.moneyDecimalString(with: active.currency)
        self.alreadyPaid = active.alreadyPaidCents?.moneyDecimalString(with: active.currency)
        self.monthlyPayment = active.monthlyPaymentCents?.moneyDecimalString(with: active.currency)
        self.isIncomePlanned = active.isIncomePlanned
        self.selectedActiveIncomeType = active.plannedIncomeType
        self.annualPercent = active.annualIncomePercent?.percentDecimalString()
        self.monthlyPlannedIncome = active.monthlyPlannedIncomeCents?.moneyDecimalString(with: active.currency)
        self.reminderViewModel = ReminderViewModel(reminder: active.reminder)
    }
    
    func loadData() -> Promise<Void> {
        return isNew ? loadDefaults() : loadActive()
    }
    
    func loadDefaults() -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadActiveTypes()).asVoid()
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    private func loadActiveTypes() -> Promise<[ActiveType]> {
        return  firstly {
                    activesCoordinator.indexActiveTypes()
                }.get { activeTypes in
                    self.activeTypes = activeTypes.map { ActiveTypeViewModel(activeType: $0) }
                }
    }
        
    private func loadActive() -> Promise<Void> {
        guard let activeId = activeId else {
            return Promise(error: ActiveError.activeIsNotSpecified)
        }
        return  firstly {
                    activesCoordinator.showActive(by: activeId)
                }.get { active in
                    self.set(active: active)
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
    
    func removeActive(deleteTransactions: Bool) -> Promise<Void> {
        guard let activeId = activeId else {
            return Promise(error: ActiveError.activeIsNotSpecified)
        }
        return activesCoordinator.destroyActive(by: activeId, deleteTransactions: deleteTransactions)
    }
}

// Creation
extension ActiveEditViewModel {
    func create() -> Promise<Void> {
        return activesCoordinator.createActive(with: creationForm()).asVoid()
    }
    
    func isCreationFormValid() -> Bool {
        return creationForm().validate() == nil
    }
    
    private func creationForm() -> ActiveCreationForm {        
        return ActiveCreationForm(basketId: basketId(by: basketType),
                                  activeTypeId: selectedActiveType?.id,
                                  name: name,
                                  iconURL: selectedIconURL,
                                  currency: selectedCurrency?.code,
                                  costCents: costToSave.intMoney(with: selectedCurrency),
                                  monthlyPaymentCents: monthlyPayment?.intMoney(with: selectedCurrency),
                                  annualIncomePercent: annualPercent?.intPercent(),
                                  monthlyPlannedIncomeCents: monthlyPlannedIncome?.intMoney(with: selectedCurrency),
                                  goalAmountCents: goal?.intMoney(with: selectedCurrency),
                                  alreadyPaidCents: alreadyPaid?.intMoney(with: selectedCurrency),
                                  plannedIncomeType: selectedActiveIncomeType,
                                  isIncomePlanned: isIncomePlanned,
                                  reminderAttributes: reminderViewModel.reminderAttributes)
    }
    
    private func basketId(by basketType: BasketType) -> Int? {
        guard let session = accountCoordinator.currentSession else { return nil }
        
        switch basketType {
        case .joy:
            return session.joyBasketId
        case .risk:
            return session.riskBasketId
        case .safe:
            return session.safeBasketId
        }
    }
}

// Updating
extension ActiveEditViewModel {
    func update() -> Promise<Void> {
        return activesCoordinator.updateActive(with: updatingForm())
    }
    
    func isUpdatingFormValid() -> Bool {
        return updatingForm().validate() == nil
    }
    
    private func updatingForm() -> ActiveUpdatingForm {        
        return ActiveUpdatingForm(id: active?.id,
                                  name: name,
                                  iconURL: selectedIconURL,
                                  costCents: costToSave.intMoney(with: selectedCurrency),
                                  monthlyPaymentCents: monthlyPayment?.intMoney(with: selectedCurrency),
                                  annualIncomePercent: annualPercent?.intPercent(),
                                  monthlyPlannedIncomeCents: monthlyPlannedIncome?.intMoney(with: selectedCurrency),
                                  goalAmountCents: goal?.intMoney(with: selectedCurrency),
                                  plannedIncomeType: selectedActiveIncomeType,
                                  isIncomePlanned: isIncomePlanned,
                                  reminderAttributes: reminderViewModel.reminderAttributes)
    }
}
