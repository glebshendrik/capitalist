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
    case statistics
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
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         activesCoordinator: ActivesCoordinatorProtocol) {
        self.activesCoordinator = activesCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, accountCoordinator: accountCoordinator)
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
        guard let activeViewModel = activeViewModel else { return [] }
        var fields: [EntityInfoField] = [IconInfoField(fieldId: ActiveInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: basketType.iconCategory.defaultIconName,
                                                       backgroundImageName: basketType.iconBackgroundName(size: .large)),
                                         BasicInfoField(fieldId: ActiveInfoField.activeType.rawValue,
                                                        title: "Тип актива",
                                                        value: activeViewModel.activeTypeName)]
        if activeViewModel.isGoal {
            fields.append(BasicInfoField(fieldId: ActiveInfoField.goal.rawValue,
                                         title: "Хочу накопить",
                                         value: activeViewModel.goalAmountRounded))
        }
        
        fields.append(BasicInfoField(fieldId: ActiveInfoField.cost.rawValue,
                                     title: activeViewModel.activeType.costTitle,
                                     value: activeViewModel.costRounded))
        
        if activeViewModel.areExpensesPlanned {
            fields.append(BasicInfoField(fieldId: ActiveInfoField.plannedAtPeriod.rawValue,
                                         title: activeViewModel.activeType.monthlyPaymentTitle,
                                         value: activeViewModel.plannedAtPeriod))
        }
        
        fields.append(BasicInfoField(fieldId: ActiveInfoField.invested.rawValue,
                                     title: "Все инвестиции за \(defaultPeriodTitle)",
                                     value: activeViewModel.investedRounded))
        
        if !activeViewModel.onlyBuyingAssets {
            fields.append(contentsOf: [BasicInfoField(fieldId: ActiveInfoField.spent.rawValue,
                                                      title: "Расходы за \(defaultPeriodTitle)",
                                                      value: activeViewModel.spentRounded),
                                       BasicInfoField(fieldId: ActiveInfoField.bought.rawValue,
                                                      title: "\(activeViewModel.activeType.buyingAssetsTitle) за \(defaultPeriodTitle)",
                                                      value: activeViewModel.boughtRounded)])
        }
        
        
        fields.append(SwitchInfoField(fieldId: ActiveInfoField.hasIncomeSwitch.rawValue,
                                      title: "Отображать источник дохода",
                                      value: isIncomePlanned))
        
        if let annualPercent = activeViewModel.annualPercent,
            activeViewModel.active.plannedIncomeType == .annualPercents {
            
            fields.append(BasicInfoField(fieldId: ActiveInfoField.annualIncome.rawValue,
                                         title: "Доходность",
                                         value: annualPercent))
        }
        
        if let monthlyPlannedIncome = activeViewModel.monthlyPlannedIncome,
            activeViewModel.active.plannedIncomeType == .monthlyIncome {
            
            fields.append(BasicInfoField(fieldId: ActiveInfoField.monthlyPlannedIncome.rawValue,
                                         title: "Доход в месяц",
                                         value: monthlyPlannedIncome))
        }
        
        fields.append(ReminderInfoField(fieldId: ActiveInfoField.reminder.rawValue,
                                        reminder: reminder))
        fields.append(contentsOf: [ButtonInfoField(fieldId: ActiveInfoField.statistics.rawValue,
                                                   title: "Статистика",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionDevidents.rawValue,
                                                   title: "Дивиденды",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionInvest.rawValue,
                                                   title: "Инвестировать",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ActiveInfoField.transactionSell.rawValue,
                                                   title: "Продать",
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return activesCoordinator.updateActive(with: updateForm())
    }
         
    private func updateForm() -> ActiveUpdatingForm {
        return ActiveUpdatingForm(id: activeViewModel?.id,
                                  name: activeViewModel?.name,
                                  iconURL: selectedIconURL,
                                  costCents: activeViewModel?.active.costCents,
                                  monthlyPaymentCents: activeViewModel?.active.monthlyPaymentCents,
                                  annualIncomePercent: activeViewModel?.active.annualIncomePercent,
                                  monthlyPlannedIncomeCents: activeViewModel?.active.monthlyPlannedIncomeCents,
                                  goalAmountCents: activeViewModel?.active.goalAmountCents,
                                  plannedIncomeType: activeViewModel?.active.plannedIncomeType,
                                  isIncomePlanned: isIncomePlanned,
                                  reminderAttributes: reminder.reminderAttributes)
    }
}
