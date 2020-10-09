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
    let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
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
    var costCentsToSave: Int {
        return costToSave.intMoney(with: selectedCurrency) ?? 0
    }
    var passedCostCents: Int?
    
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
    
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    var isMovingFundsFromWallet: Bool = true
    var selectedSource: ExpenseSourceViewModel? = nil
    var activeCreationTransactionAttributes: ActiveCreationTransactionNestedAttributes? {
        guard isNew, costCentsToSave > 0 else { return nil }
        return ActiveCreationTransactionNestedAttributes(id: nil, sourceId: isMovingFundsFromWallet ? selectedSource?.id : nil)
    }
    
    var reminderViewModel: ReminderViewModel = ReminderViewModel()
    
    var reminderTitle: String {
        return reminderViewModel.isReminderSet
            ? NSLocalizedString("Изменить напоминание", comment: "Изменить напоминание")
            : NSLocalizedString("Установить напоминание", comment: "Установить напоминание")
    }
    
    var reminder: String? {
        return reminderViewModel.reminder
    }
            
    var title: String {
        return isNew
            ? NSLocalizedString("Новый актив", comment: "Новый актив")
            : NSLocalizedString("Актив", comment: "Актив")
    }
    
    var costTitle: String {
        return selectedActiveType?.costTitle ?? NSLocalizedString("Стоимость актива", comment: "Стоимость актива")
    }
    
    var monthlyPaymentTitle: String {
        return selectedActiveType?.monthlyPaymentTitle ?? NSLocalizedString("Планирую инвестировать в месяц", comment: "Планирую инвестировать в месяц")        
    }
        
    var iconDefaultImageName: String { return TransactionableType.active.defaultIconName(basketType: basketType) }
    
    var accountConnected: Bool {
        guard let accountConnectionAttributes = accountConnectionAttributes else {
            return false
        }
        
        return accountConnectionAttributes.shouldDestroy == nil
    }
    
    var bankButtonTitle: String {
        return accountConnected
            ? NSLocalizedString("Отключить банк", comment: "Отключить банк")
            : NSLocalizedString("Подключить банк", comment: "Подключить банк")
    }
    
    var expenseSourceIconURL: URL? { return selectedSource?.iconURL }
    var expenseSourceIconDefaultImageName: String { return TransactionableType.expenseSource.defaultIconName }
    var expenseSourceName: String? { return selectedSource?.name }
    var expenseSourceAmount: String? { return selectedSource?.amount }
    var expenseSourceCurrency: Currency? { return selectedSource?.currency }
    var expenseSourceCurrencyCode: String? { return expenseSourceCurrency?.code }
    
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
    
    var reminderHidden: Bool {
        return !isNew
    }
    
    var iconPenHidden: Bool {
        return !canChangeIcon
    }
    
    var customIconHidden: Bool {
        return accountConnected
    }
    
    var bankIconHidden: Bool {
        return !accountConnected
    }
    
    var removeButtonHidden: Bool { return isNew }
        
    var movingFundsFromWalletSelectionHidden: Bool {
        return !isNew
    }
    
    var expenseSourceFieldHidden: Bool {
        return !isNew || !isMovingFundsFromWallet
    }
    
    // Permissions
    
    var canChangeIcon: Bool {
        return !accountConnected
    }
    
    var canChangeCurrency: Bool {
        return !accountConnected && isNew
    }
    
    var canChangeAmount: Bool {
        return !accountConnected
    }
    
    var canChangeActiveType: Bool { return isNew }
        
    var iconType: IconType {
        return .raster
    }
    
    init(activesCoordinator: ActivesCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
        self.accountCoordinator = accountCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
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
        self.cost = (passedCostCents ?? active.costCents).moneyDecimalString(with: active.currency)
        self.goal = active.goalAmountCents?.moneyDecimalString(with: active.currency)
        self.alreadyPaid = active.alreadyPaidCents?.moneyDecimalString(with: active.currency)
        self.monthlyPayment = active.monthlyPaymentCents?.moneyDecimalString(with: active.currency)
        self.isIncomePlanned = active.isIncomePlanned
        self.selectedActiveIncomeType = active.plannedIncomeType
        self.annualPercent = active.annualIncomePercent?.percentDecimalString()
        self.monthlyPlannedIncome = active.monthlyPlannedIncomeCents?.moneyDecimalString(with: active.currency)
        self.reminderViewModel = ReminderViewModel(reminder: active.reminder)
                
//        if let accountConnection = active.accountConnection {
//            accountConnectionAttributes =
//                AccountConnectionNestedAttributes(id: accountConnection.id,
//                                                  accountId: accountConnection.account.id,
//                                                  shouldDestroy: nil)
//        }
    }
    
    func set(costCents: Int?) {
        self.passedCostCents = costCents
    }
    
    func loadData() -> Promise<Void> {
        return isNew ? loadDefaults() : loadActive()
    }
    
    func loadDefaults() -> Promise<Void> {
        return when(fulfilled: loadDefaultCurrency(), loadDefaultExpenseSource(), loadActiveTypes()).asVoid()
    }
    
    func loadDefaultCurrency() -> Promise<Void> {
        return  firstly {
                    accountCoordinator.loadCurrentUser()
                }.done { user in
                    self.selectedCurrency = user.currency
                }
    }
    
    func loadDefaultExpenseSource() -> Promise<Void> {
        return  firstly {
                    expenseSourcesCoordinator.first()
                }.get { expenseSource in
                    guard let expenseSource = expenseSource else {
                        self.selectedSource = nil
                        return
                    }
                    self.selectedSource = ExpenseSourceViewModel(expenseSource: expenseSource)
                }.asVoid()
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
                                  costCents: costCentsToSave,
                                  monthlyPaymentCents: monthlyPayment?.intMoney(with: selectedCurrency),
                                  annualIncomePercent: annualPercent?.intPercent(),
                                  monthlyPlannedIncomeCents: monthlyPlannedIncome?.intMoney(with: selectedCurrency),
                                  goalAmountCents: goal?.intMoney(with: selectedCurrency),
                                  alreadyPaidCents: alreadyPaid?.intMoney(with: selectedCurrency),
                                  plannedIncomeType: selectedActiveIncomeType,
                                  isIncomePlanned: isIncomePlanned,
                                  reminderAttributes: reminderViewModel.reminderAttributes,
                                  accountConnectionAttributes: accountConnectionAttributes,
                                  activeCreationTransactionAttributes: activeCreationTransactionAttributes)
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
                                  reminderAttributes: reminderViewModel.reminderAttributes,
                                  accountConnectionAttributes: accountConnectionAttributes)
    }
}

//// Bank Connection
//extension ActiveEditViewModel {
//    func connect(accountViewModel: AccountViewModel, connection: Connection) {
//        selectedCurrency = accountViewModel.currency
//        selectedIconURL = connection.providerLogoURL
//
//        if name == nil {
//            name = accountViewModel.name
//        }
//
//        cost = accountViewModel.amount
//
//        var accountConnectionId: Int? = nil
//        if  let accountConnectionAttributes = accountConnectionAttributes,
//            accountConnectionAttributes.accountId == accountViewModel.id {
//
//            accountConnectionId = accountConnectionAttributes.id
//        }
//
//        accountConnectionAttributes =
//            AccountConnectionNestedAttributes(id: accountConnectionId,
//                                              accountId: accountViewModel.id,
//                                              shouldDestroy: nil)
//    }
//
//    func removeAccountConnection() {
//        accountConnectionAttributes?.id = active?.accountConnection?.id
//        accountConnectionAttributes?.shouldDestroy = true
//        selectedIconURL = nil
//    }
//}
