//
//  ExpenseSourceInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum ExpenseSourceInfoField : String {
    case icon
    case balance
    case creditLimit
    case credit
    case statistics
    case transactionIncome
    case transactionExpense
    
    var identifier: String {
        return rawValue
    }
}

enum ExpenseSourceInfoError : Error {
    case expenseSourceIsNotSpecified
}

class ExpenseSourceInfoViewModel : EntityInfoViewModel {
    private let expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol
    
    var expenseSourceViewModel: ExpenseSourceViewModel?
    
    var selectedIconURL: URL? = nil
    
    var expenseSource: ExpenseSource? {
        return expenseSourceViewModel?.expenseSource
    }
    
    override var transactionable: Transactionable? {
        return expenseSourceViewModel
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         expenseSourcesCoordinator: ExpenseSourcesCoordinatorProtocol) {
        self.expenseSourcesCoordinator = expenseSourcesCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(expenseSource: ExpenseSourceViewModel?) {
        self.expenseSourceViewModel = expenseSource
        self.selectedIconURL = expenseSource?.iconURL
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = expenseSourceViewModel?.id else { return Promise(error: ExpenseSourceInfoError.expenseSourceIsNotSpecified)}
        return  firstly {
                    expenseSourcesCoordinator.show(by: entityId)
                }.get { expenseSource in
                    self.set(expenseSource: ExpenseSourceViewModel(expenseSource: expenseSource))
                }.asVoid()
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        var fields: [EntityInfoField] = [IconInfoField(fieldId: ExpenseSourceInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: TransactionableType.expenseSource.defaultIconName),
                                         BasicInfoField(fieldId: ExpenseSourceInfoField.balance.rawValue,
                                                        title: "Баланс",
                                                        value: expenseSourceViewModel?.amount)]
        if let expenseSourceViewModel = expenseSourceViewModel, expenseSourceViewModel.hasCreditLimit {
            fields.append(BasicInfoField(fieldId: ExpenseSourceInfoField.creditLimit.rawValue,
                                         title: "Кредитный лимит",
                                         value: expenseSourceViewModel.creditLimit))
        }
        if let expenseSourceViewModel = expenseSourceViewModel, expenseSourceViewModel.inCredit {
            fields.append(BasicInfoField(fieldId: ExpenseSourceInfoField.credit.rawValue,
                                         title: "Ваш кредитный долг",
                                         value: expenseSourceViewModel.credit))
        }
        fields.append(contentsOf: [ButtonInfoField(fieldId: ExpenseSourceInfoField.statistics.rawValue,
                                                   title: "Статистика",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionIncome.rawValue,
                                                   title: "Добавить доход",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: ExpenseSourceInfoField.transactionExpense.rawValue,
                                                   title: "Добавить расход",
                                                   iconName: nil,
                                                   isEnabled: true)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return expenseSourcesCoordinator.update(with: updateForm())
    }
         
    private func updateForm() -> ExpenseSourceUpdatingForm {
        return ExpenseSourceUpdatingForm(id: expenseSourceViewModel?.id,
                                        name: expenseSourceViewModel?.name,
                                        iconURL: selectedIconURL,
                                        amountCents: expenseSourceViewModel?.expenseSource.amountCents,
                                        creditLimitCents: expenseSourceViewModel?.expenseSource.creditLimitCents,
                                        accountConnectionAttributes:  nil)
    }
}
