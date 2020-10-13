//
//  IncomeSourceInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum IncomeSourceInfoField : String {
    case icon
    case reminder
    case income
    case plannedIncome
    case statistics
    case transaction
    case description
    
    var identifier: String {
        return rawValue
    }
}

enum IncomeSourceInfoError : Error {
    case incomeSourceIsNotSpecified
}

class IncomeSourceInfoViewModel : EntityInfoViewModel {
    private let incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol
    
    var incomeSourceViewModel: IncomeSourceViewModel?
    
    var reminder: ReminderViewModel = ReminderViewModel()
    var selectedIconURL: URL? = nil
    
    var incomeSource: IncomeSource? {
        return incomeSourceViewModel?.incomeSource
    }
    
    var isBorrow: Bool {
        return incomeSourceViewModel?.isBorrowOrReturn ?? false
    }
    
    var transactionTitle: String {
        return isBorrow
            ? NSLocalizedString("Добавить займ", comment: "Добавить займ")
            : NSLocalizedString("Добавить доход", comment: "Добавить доход")
    }
    
    override var transactionable: Transactionable? {
        return incomeSourceViewModel
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol,
         borrowsCoordinator: BorrowsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         incomeSourcesCoordinator: IncomeSourcesCoordinatorProtocol) {
        self.incomeSourcesCoordinator = incomeSourcesCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, creditsCoordinator: creditsCoordinator, borrowsCoordinator: borrowsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(incomeSource: IncomeSourceViewModel?) {
        self.incomeSourceViewModel = incomeSource
        self.reminder = ReminderViewModel(reminder: incomeSourceViewModel?.incomeSource.reminder)
        self.selectedIconURL = incomeSource?.iconURL
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = incomeSourceViewModel?.id else { return Promise(error: IncomeSourceInfoError.incomeSourceIsNotSpecified)}
        return  firstly {
                    incomeSourcesCoordinator.show(by: entityId)
                }.get { incomeSource in
                    self.set(incomeSource: IncomeSourceViewModel(incomeSource: incomeSource))
                }.asVoid()
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        var fields = [EntityInfoField]()
        
        fields.append(IconInfoField(fieldId: IncomeSourceInfoField.icon.rawValue,
                                    iconType: .raster,
                                    iconURL: selectedIconURL,
                                    placeholder: TransactionableType.incomeSource.defaultIconName))
        
        if let description = incomeSourceViewModel?.description {
            fields.append(DescriptionInfoField(fieldId: IncomeSourceInfoField.description.rawValue,
                                               description: description))
        }
        
        fields.append(BasicInfoField(fieldId: IncomeSourceInfoField.income.rawValue,
                                     title: NSLocalizedString("Доход в этом месяце", comment: "Доход в этом месяце"),
                                     value: incomeSourceViewModel?.amount))

        if let plannedAtPeriod = incomeSourceViewModel?.plannedAtPeriod {
            fields.append(BasicInfoField(fieldId: IncomeSourceInfoField.plannedIncome.rawValue,
                                         title: NSLocalizedString("Запланировано", comment: "Запланировано"),
                                         value: plannedAtPeriod))
        }
        fields.append(ReminderInfoField(fieldId: IncomeSourceInfoField.reminder.rawValue,
                                        reminder: reminder))
        fields.append(contentsOf: [ButtonInfoField(fieldId: IncomeSourceInfoField.statistics.rawValue,
                                                   title: NSLocalizedString("Статистика", comment: "Статистика"),
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: IncomeSourceInfoField.transaction.rawValue,
                                                   title: transactionTitle,
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return incomeSourcesCoordinator.update(with: updateForm())
    }
         
    private func updateForm() -> IncomeSourceUpdatingForm {
        return IncomeSourceUpdatingForm(id: incomeSourceViewModel?.id,
                                        iconURL: selectedIconURL,
                                        name: incomeSourceViewModel?.name,
                                        monthlyPlannedCents: incomeSourceViewModel?.incomeSource.plannedCentsAtPeriod,
                                        description: incomeSourceViewModel?.description,
                                        reminderAttributes: reminder.reminderAttributes)
    }
}
