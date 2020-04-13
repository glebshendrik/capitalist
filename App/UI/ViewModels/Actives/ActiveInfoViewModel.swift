//
//  ActiveInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ActiveInfoField : String {
    case icon
    case activeType
    case goal
    case cost
    case plannedAtPeriod
    case invested
    case spent
    case bought
    case hasIncomeSwitch
    case annualIncome
    case monthlyPlannedIncome
    case reminder
    case bank
    case statistics
    case costChange
    case transactionDevidents
    case transactionInvest
    case transactionSell
    
    var identifier: String {
        return rawValue
    }
}

enum ActiveInfoError : Error {
    case activeIsNotSpecified
}

class ActiveInfoViewModel : EntityInfoViewModel {
    private let activesCoordinator: ActivesCoordinatorProtocol
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    var activeViewModel: ActiveViewModel?
    
    var reminder: ReminderViewModel = ReminderViewModel()
    var selectedIconURL: URL? = nil
    var isIncomePlanned: Bool = false
    var incomeSourceViewModel: IncomeSourceViewModel?
    var accountConnectionAttributes: AccountConnectionNestedAttributes? = nil
    
    var selectedAccountViewModel: AccountViewModel? = nil
    
    var basketType: BasketType {
        return activeViewModel?.basketType ?? .joy
    }
    
    var active: Active? {
        return activeViewModel?.active
    }
    
    override var transactionable: Transactionable? {
        return activeViewModel
    }
    
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
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol,
         bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, creditsCoordinator: creditsCoordinator, borrowsCoordinator: borrowsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(active: ActiveViewModel?) {
        self.activeViewModel = active
        self.reminder = ReminderViewModel(reminder: activeViewModel?.active.reminder)
        self.selectedIconURL = active?.iconURL
        self.isIncomePlanned = active?.active.isIncomePlanned ?? false
        if let incomeSource = active?.active.incomeSource {
            self.incomeSourceViewModel = IncomeSourceViewModel(incomeSource: incomeSource)
        }
        else {
            self.incomeSourceViewModel = nil
        }
        self.selectedAccountViewModel = nil
        if let accountConnection = active?.active.accountConnection {
            accountConnectionAttributes =
                AccountConnectionNestedAttributes(id: accountConnection.id,
                                                  providerConnectionId: accountConnection.providerConnection.id,
                                                  accountId: accountConnection.accountId,
                                                  accountName: accountConnection.accountName,
                                                  nature: accountConnection.nature,
                                                  currencyCode: accountConnection.currencyCode,
                                                  balance: accountConnection.balance,
                                                  connectionId: accountConnection.connectionId,
                                                  shouldDestroy: nil)
        }
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = activeViewModel?.id else { return Promise(error: ActiveInfoError.activeIsNotSpecified)}
        return  firstly {
                    activesCoordinator.showActive(by: entityId)
                }.get { active in
                    self.set(active: ActiveViewModel(active: active))
                }.asVoid()
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        guard let activeViewModel = activeViewModel else { return [] }
        var fields: [EntityInfoField] = [IconInfoField(fieldId: ActiveInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,           
                                                       placeholder: activeViewModel.defaultIconName),
                                         BasicInfoField(fieldId: ActiveInfoField.activeType.rawValue,
                                                        title: NSLocalizedString("Тип актива", comment: "Тип актива"),
                                                        value: activeViewModel.activeTypeName)]
        if activeViewModel.isGoal {
            fields.append(BasicInfoField(fieldId: ActiveInfoField.goal.rawValue,
                                         title: NSLocalizedString("Хочу накопить", comment: "Хочу накопить"),
                                         value: activeViewModel.goalAmount))
        }
        
        fields.append(BasicInfoField(fieldId: ActiveInfoField.cost.rawValue,
                                     title: activeViewModel.activeType.costTitle,
                                     value: activeViewModel.cost))
        
        if activeViewModel.areExpensesPlanned {
            fields.append(BasicInfoField(fieldId: ActiveInfoField.plannedAtPeriod.rawValue,
                                         title: activeViewModel.activeType.monthlyPaymentTitle,
                                         value: activeViewModel.plannedAtPeriod))
        }
        
        fields.append(BasicInfoField(fieldId: ActiveInfoField.invested.rawValue,
                                     title: String(format: NSLocalizedString("Все инвестиции за %@", comment: "Все инвестиции за %@"), defaultPeriodTitle),
                                     value: activeViewModel.invested))
        
        if !activeViewModel.onlyBuyingAssets {
            fields.append(contentsOf: [BasicInfoField(fieldId: ActiveInfoField.spent.rawValue,
                                                      title: String(format: NSLocalizedString("Расходы за %@", comment: "Расходы за %@"), defaultPeriodTitle),
                                                      value: activeViewModel.spent),
                                       BasicInfoField(fieldId: ActiveInfoField.bought.rawValue,
                                                      title: String(format: NSLocalizedString("%@ за %@", comment: "%@ за %@"), activeViewModel.activeType.buyingAssetsTitle, defaultPeriodTitle),
                                                      value: activeViewModel.bought)])
        }
        
        
        fields.append(SwitchInfoField(fieldId: ActiveInfoField.hasIncomeSwitch.rawValue,
                                      title: NSLocalizedString("Отображать источник дохода", comment: "Отображать источник дохода"),
                                      value: isIncomePlanned))
        
        if let annualPercent = activeViewModel.annualPercent,
            activeViewModel.active.plannedIncomeType == .annualPercents {
            
            fields.append(BasicInfoField(fieldId: ActiveInfoField.annualIncome.rawValue,
                                         title: NSLocalizedString("Доходность", comment: "Доходность"),
                                         value: annualPercent))
        }
        
        if let monthlyPlannedIncome = activeViewModel.monthlyPlannedIncome,
            activeViewModel.active.plannedIncomeType == .monthlyIncome {
            
            fields.append(BasicInfoField(fieldId: ActiveInfoField.monthlyPlannedIncome.rawValue,
                                         title: NSLocalizedString("Доход в месяц", comment: "Доход в месяц"),
                                         value: monthlyPlannedIncome))
        }
        
        fields.append(ReminderInfoField(fieldId: ActiveInfoField.reminder.rawValue,
                                        reminder: reminder))
        
//        fields.append(ButtonInfoField(fieldId: ExpenseSourceInfoField.bank.rawValue,
//                                      title: bankButtonTitle,
//                                      iconName: nil,
//                                      isEnabled: true))
        
        fields.append(contentsOf: [ButtonInfoField(fieldId: ActiveInfoField.statistics.rawValue,
                                                   title: NSLocalizedString("Статистика", comment: "Статистика"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.costChange.rawValue,
                                                   title: NSLocalizedString("Переоценить актив", comment: "Переоценить актив"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionDevidents.rawValue,
                                                   title: NSLocalizedString("Дивиденды", comment: "Дивиденды"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionInvest.rawValue,
                                                   title: NSLocalizedString("Инвестировать", comment: "Инвестировать"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionSell.rawValue,
                                                   title: NSLocalizedString("Продать", comment: "Продать"),
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return activesCoordinator.updateActive(with: updateForm())
    }
         
    private func updateForm() -> ActiveUpdatingForm {
        let costCents = selectedAccountViewModel?.amountCents ?? activeViewModel?.active.costCents
        
        return ActiveUpdatingForm(id: activeViewModel?.id,
                                  name: activeViewModel?.name,
                                  iconURL: selectedIconURL,
                                  costCents: costCents,
                                  monthlyPaymentCents: activeViewModel?.active.monthlyPaymentCents,
                                  annualIncomePercent: activeViewModel?.active.annualIncomePercent,
                                  monthlyPlannedIncomeCents: activeViewModel?.active.monthlyPlannedIncomeCents,
                                  goalAmountCents: activeViewModel?.active.goalAmountCents,
                                  plannedIncomeType: activeViewModel?.active.plannedIncomeType,
                                  isIncomePlanned: isIncomePlanned,
                                  reminderAttributes: reminder.reminderAttributes,
                                  accountConnectionAttributes: accountConnectionAttributes)
    }
}

// Bank Connection
extension ActiveInfoViewModel {
    func connect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection) {
        selectedIconURL = providerConnection.logoURL
        selectedAccountViewModel = accountViewModel
        
        var accountConnectionId: Int? = nil
        if  let accountConnectionAttributes = accountConnectionAttributes,
            accountConnectionAttributes.accountId == accountViewModel.id {
            
            accountConnectionId = accountConnectionAttributes.id
        }
        
        accountConnectionAttributes =
            AccountConnectionNestedAttributes(id: accountConnectionId,
                                              providerConnectionId: providerConnection.id,
                                              accountId: accountViewModel.id,
                                              accountName: accountViewModel.name,
                                              nature: accountViewModel.nature,
                                              currencyCode: accountViewModel.currencyCode,
                                              balance: accountViewModel.amountCents ?? 0,
                                              connectionId: providerConnection.connectionId,
                                              shouldDestroy: nil)
    }
    
    func removeAccountConnection() {
        accountConnectionAttributes?.id = active?.accountConnection?.id
        accountConnectionAttributes?.shouldDestroy = true
        selectedIconURL = nil
    }
}
