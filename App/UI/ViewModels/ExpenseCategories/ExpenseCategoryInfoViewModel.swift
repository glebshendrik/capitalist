//
//  ExpenseCategoryInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseCategoryInfoField : String {
    case icon
    case reminder
    case expense
    case plannedExpense
    case statistics
    case transaction
    
    var identifier: String {
        return rawValue
    }
}

enum ExpenseCategoryInfoError : Error {
    case expenseCategoryIsNotSpecified
}

class ExpenseCategoryInfoViewModel : EntityInfoViewModel {
    private let expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol
    
    var expenseCategoryViewModel: ExpenseCategoryViewModel?
    
    var reminder: ReminderViewModel = ReminderViewModel()
    var selectedIconURL: URL? = nil
    
    var basketType: BasketType {
        return expenseCategoryViewModel?.basketType ?? .joy
    }
    
    var expenseCategory: ExpenseCategory? {
        return expenseCategoryViewModel?.expenseCategory
    }
    
    override var transactionable: Transactionable? {
        return expenseCategoryViewModel
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseCategoriesCoordinator: ExpenseCategoriesCoordinatorProtocol) {
        self.expenseCategoriesCoordinator = expenseCategoriesCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(expenseCategory: ExpenseCategoryViewModel?) {
        self.expenseCategoryViewModel = expenseCategory
        self.reminder = ReminderViewModel(reminder: expenseCategoryViewModel?.expenseCategory.reminder)
        self.selectedIconURL = expenseCategory?.iconURL
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = expenseCategoryViewModel?.id else { return Promise(error: ExpenseCategoryInfoError.expenseCategoryIsNotSpecified)}
        return  firstly {
                    expenseCategoriesCoordinator.show(by: entityId)
                }.get { expenseCategory in
                    self.set(expenseCategory: ExpenseCategoryViewModel(expenseCategory: expenseCategory))
                }.asVoid()
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        var fields: [EntityInfoField] = [IconInfoField(fieldId: ExpenseCategoryInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: basketType.iconCategory.defaultIconName,
                                                       backgroundImageName: basketType.iconBackgroundName(size: .large)),
                                         BasicInfoField(fieldId: ExpenseCategoryInfoField.expense.rawValue,
                                                        title: "Расход в этом месяце",
                                                        value: expenseCategoryViewModel?.amountRounded)]
        if let plannedAtPeriod = expenseCategoryViewModel?.plannedAtPeriod {
            fields.append(BasicInfoField(fieldId: ExpenseCategoryInfoField.plannedExpense.rawValue,
                                         title: "Запланировано",
                                         value: plannedAtPeriod))
        }
        fields.append(ReminderInfoField(fieldId: ExpenseCategoryInfoField.reminder.rawValue,
                                        reminder: reminder))
        fields.append(contentsOf: [ButtonInfoField(fieldId: ExpenseCategoryInfoField.statistics.rawValue,
                                                   title: "Статистика",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ExpenseCategoryInfoField.transaction.rawValue,
                                                   title: "Добавить расход",
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return expenseCategoriesCoordinator.update(with: updateForm())
    }
         
    private func updateForm() -> ExpenseCategoryUpdatingForm {
        return ExpenseCategoryUpdatingForm(id: expenseCategoryViewModel?.id,
                                        iconURL: selectedIconURL,
                                        name: expenseCategoryViewModel?.name,
                                        monthlyPlannedCents: expenseCategoryViewModel?.expenseCategory.plannedCentsAtPeriod,
                                        reminderAttributes: reminder.reminderAttributes)
    }
}
