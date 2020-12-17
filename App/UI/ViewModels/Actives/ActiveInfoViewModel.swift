//
//  ActiveInfoViewModel.swift
//  Capitalist
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
    case investmentsInCost
    case fullSaleProfit
    case plannedAtPeriod
    case invested
    case spent
    case bought
    case hasIncomeSwitch
    case annualIncome
    case monthlyPlannedIncome
    case reminder
    case statistics
    case costChange
    case transactionDevidents
    case transactionInvest
    case transactionSell
    case goalHeader
    case profitHeader
    case planned
    case investments
    
    var identifier: String {
        return rawValue
    }
}

enum ActiveInfoError : Error {
    case activeIsNotSpecified
}

class ActiveInfoViewModel : EntityInfoViewModel {
    private let activesCoordinator: ActivesCoordinatorProtocol
    
    var activeViewModel: ActiveViewModel?
    
    var reminder: ReminderViewModel = ReminderViewModel()
    var selectedIconURL: URL? = nil
    var isIncomePlanned: Bool = false
    var incomeSourceViewModel: IncomeSourceViewModel?
    
    var basketType: BasketType {
        return activeViewModel?.basketType ?? .joy
    }
    
    var active: Active? {
        return activeViewModel?.active
    }
    
    override var transactionable: Transactionable? {
        return activeViewModel
    }
        
    var iconType: IconType {
        return .raster
    }
    
    var iconField: IconInfoField {
        return IconInfoField(fieldId: ActiveInfoField.icon.rawValue,
                             iconType: .raster,
                             iconURL: selectedIconURL,
                             placeholder: activeViewModel?.defaultIconName,
                             backgroundColor: basketType.iconBackgroundColor)
    }
    
    var activeTypeField: BasicInfoField {
        return BasicInfoField(fieldId: ActiveInfoField.activeType.rawValue,
                              title: NSLocalizedString("Тип актива", comment: "Тип актива"),
                              value: activeViewModel?.activeTypeName)
    }
    
    var goalField: BasicInfoField? {
        guard let activeViewModel = activeViewModel, activeViewModel.isGoal else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.goal.rawValue,
                              title: NSLocalizedString("Хочу накопить", comment: "Хочу накопить"),
                              value: activeViewModel.goalAmount)
    }
    
    var costField: BasicInfoField {
        return BasicInfoField(fieldId: ActiveInfoField.cost.rawValue,
                              title: activeViewModel?.activeType.costTitle,
                              value: activeViewModel?.cost)
    }
    
    var investmentsInCostField: BasicInfoField {
        return BasicInfoField(fieldId: ActiveInfoField.investmentsInCost.rawValue,
                              title: NSLocalizedString("Инвестиций в активе", comment: "Инвестиций в активе"),
                              value: activeViewModel?.investmentsInCost)
    }
    
    var fullSaleProfitField: BasicInfoField {
        return BasicInfoField(fieldId: ActiveInfoField.fullSaleProfit.rawValue,
                              title: NSLocalizedString("Доходность", comment: "Доходность"),
                              value: activeViewModel?.fullSaleProfit,
                              valueColorAsset: activeViewModel?.fullSaleProfitColorAsset ?? .white100)
    }
    
    var monthlyPlannedPaymentField: BasicInfoField? {
        guard let activeViewModel = activeViewModel, activeViewModel.areExpensesPlanned else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.plannedAtPeriod.rawValue,
                              title: activeViewModel.activeType.monthlyPaymentTitle,
                              value: activeViewModel.plannedAtPeriod)
    }
    
    var investedField: BasicInfoField {
        return BasicInfoField(fieldId: ActiveInfoField.invested.rawValue,
                              title: String(format: NSLocalizedString("Все инвестиции за %@", comment: "Все инвестиции за %@"), defaultPeriodTitle),
                              value: activeViewModel?.invested)
    }
    
    var expensesField: BasicInfoField? {
        guard let activeViewModel = activeViewModel, !activeViewModel.onlyBuyingAssets else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.spent.rawValue,
                              title: String(format: NSLocalizedString("Расходы за %@", comment: "Расходы за %@"), defaultPeriodTitle),
                              value: activeViewModel.spent)
    }
    
    var purchasesField: BasicInfoField? {
        guard let activeViewModel = activeViewModel, !activeViewModel.onlyBuyingAssets else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.bought.rawValue,
                              title: String(format: NSLocalizedString("%@ за %@", comment: "%@ за %@"), activeViewModel.activeType.buyingAssetsTitle, defaultPeriodTitle),
                              value: activeViewModel.bought)
    }
    
    var incomeSourceSwitchField: SwitchInfoField {
        return SwitchInfoField(fieldId: ActiveInfoField.hasIncomeSwitch.rawValue,
                               title: NSLocalizedString("Отображать источник дохода", comment: "Отображать источник дохода"),
                               value: isIncomePlanned)
    }
    
    var annualPercentsField: BasicInfoField? {
        guard   let activeViewModel = activeViewModel,
                let annualPercent = activeViewModel.annualPercent,
                activeViewModel.active.plannedIncomeType == .annualPercents else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.annualIncome.rawValue,
                              title: NSLocalizedString("Ожидаемый годовой процент", comment: "Ожидаемый годовой процент"),
                              value: annualPercent)
    }
    
    var monthlyIncomeField: BasicInfoField? {
        guard   let activeViewModel = activeViewModel,
                let monthlyPlannedIncome = activeViewModel.monthlyPlannedIncome,
                activeViewModel.active.plannedIncomeType == .monthlyIncome else { return nil }
        return BasicInfoField(fieldId: ActiveInfoField.monthlyPlannedIncome.rawValue,
                              title: NSLocalizedString("Планируемый доход в месяц", comment: "Планируемый доход в месяц"),
                              value: monthlyPlannedIncome)
    }
    
    var reminderField: ReminderInfoField {
        return ReminderInfoField(fieldId: ActiveInfoField.reminder.rawValue,
                                 reminder: reminder)
    }
        
    var statisticsField: ButtonInfoField {
        return ButtonInfoField(fieldId: ActiveInfoField.statistics.rawValue,
                               title: NSLocalizedString("Статистика", comment: "Статистика"),
                               iconName: nil,
                               isEnabled: true)
    }
    
    var costChangeField: ButtonInfoField {
        return ButtonInfoField(fieldId: ActiveInfoField.costChange.rawValue,
                               title: NSLocalizedString("Переоценить актив", comment: "Переоценить актив"),
                               iconName: nil,
                               isEnabled: true)
    }
    
    var transactionDevidentsField: ButtonInfoField {
        return ButtonInfoField(fieldId: ActiveInfoField.transactionDevidents.rawValue,
                               title: NSLocalizedString("Дивиденды", comment: "Дивиденды"),
                               iconName: nil,
                               isEnabled: true)
    }
    
    var transactionBuyField: ButtonInfoField {
        return ButtonInfoField(fieldId: ActiveInfoField.transactionInvest.rawValue,
                               title: NSLocalizedString("Инвестировать", comment: "Инвестировать"),
                               iconName: nil,
                               isEnabled: true)
    }
    
    var transactionSellField: ButtonInfoField {
        return ButtonInfoField(fieldId: ActiveInfoField.transactionSell.rawValue,
                               title: NSLocalizedString("Продать", comment: "Продать"),
                               iconName: nil,
                               isEnabled: true)
    }
    
    var headerField: CombinedInfoField? {
        guard let activeViewModel = activeViewModel else { return nil }
        if activeViewModel.activeType.isGoalAmountRequired {
            return goalHeaderField
        }
        return profitHeaderField
    }
    
    var goalHeaderField: CombinedInfoField {
        return CombinedInfoField(fieldId: ActiveInfoField.goalHeader.rawValue,
                                 icon: iconField,
                                 main: costField,
                                 first: goalField,
                                 second: nil,
                                 third: nil)
    }
    
    var profitHeaderField: CombinedInfoField {
        return CombinedInfoField(fieldId: ActiveInfoField.profitHeader.rawValue,
                                 icon: iconField,
                                 main: costField,
                                 first: investmentsInCostField,
                                 second: fullSaleProfitField,
                                 third: nil)
    }
    
    var plannedField: CombinedInfoField {
        return CombinedInfoField(fieldId: ActiveInfoField.planned.rawValue,
                                 icon: nil,
                                 main: activeTypeField,
                                 first: monthlyPlannedPaymentField,
                                 second: annualPercentsField ?? monthlyIncomeField,
                                 third: nil)
    }
    
    var investmentsField: CombinedInfoField {
        return CombinedInfoField(fieldId: ActiveInfoField.investments.rawValue,
                                 icon: nil,
                                 main: investedField,
                                 first: expensesField,
                                 second: purchasesField,
                                 third: nil)
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
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
        var fields = [EntityInfoField]()
        
        if let headerField = headerField {
            fields.append(headerField)
        }
        
        fields.append(activeTypeField)
                        
        if let monthlyPlannedPaymentField = monthlyPlannedPaymentField {
            fields.append(monthlyPlannedPaymentField)
        }
        
        fields.append(investedField)
        
        if let expensesField = expensesField {
            fields.append(expensesField)
        }
        
        if let purchasesField = purchasesField {
            fields.append(purchasesField)
        }
                
        if let annualPercentsField = annualPercentsField {
            fields.append(annualPercentsField)
        }
        
        if let monthlyIncomeField = monthlyIncomeField {
            fields.append(monthlyIncomeField)
        }
        
        fields.append(incomeSourceSwitchField)
        fields.append(reminderField)
        
        fields.append(statisticsField)
        fields.append(costChangeField)
        fields.append(transactionDevidentsField)
        fields.append(transactionBuyField)
        fields.append(transactionSellField)
        
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return activesCoordinator.updateActive(with: updateForm())
    }
         
    private func updateForm() -> ActiveUpdatingForm {
        let costCents = activeViewModel?.active.costCents
        
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
                                  accountConnectionAttributes: nil)
    }
}
