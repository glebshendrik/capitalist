//
//  CreditInfoViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum CreditInfoField : String {
    case icon
    case creditType
    case amount
    case gotAt
    case period
    case returnAmount
    case paidAmount
    case amountLeft
    case planned
    case reminder
    case statistics
    case transaction
    
    var identifier: String {
        return rawValue
    }
}

enum CreditInfoError : Error {
    case creditIsNotSpecified
}

class CreditInfoViewModel : EntityInfoViewModel {
    private let creditsCoordinator: CreditsCoordinatorProtocol
    private let transactionsCoordinator: TransactionsCoordinatorProtocol
    
    var creditId: Int?
    var creditViewModel: CreditViewModel?
    
    var reminder: ReminderViewModel = ReminderViewModel()
    var selectedIconURL: URL? = nil
    var expenseCategoryViewModel: ExpenseCategoryViewModel?
    
    var credit: Credit? {
        return creditViewModel?.credit
    }
        
    override var title: String? {
        return creditViewModel?.name ?? "Кредит"
    }
    
    var payTitle: String? {
        guard let creditViewModel = creditViewModel else { return nil }
        return creditViewModel.isPaid ? "Кредит выплачен" : "Оплатить"
    }
    
    var payIconName: String? {
        guard let creditViewModel = creditViewModel else { return nil }
        return creditViewModel.isPaid ? nil : nil
    }
    
    var payColor: ColorAsset {
        guard let creditViewModel = creditViewModel else { return .blue5B86F7 }
        return creditViewModel.isPaid ? .dark404B6F : .blue5B86F7
    }
    
    init(transactionsCoordinator: TransactionsCoordinatorProtocol,
         accountCoordinator: AccountCoordinatorProtocol,
         creditsCoordinator: CreditsCoordinatorProtocol) {
        self.creditsCoordinator = creditsCoordinator
        self.transactionsCoordinator = transactionsCoordinator
        super.init(transactionsCoordinator: transactionsCoordinator, accountCoordinator: accountCoordinator)
    }
    
    func set(credit: CreditViewModel?) {
        self.creditId = credit?.id
        self.creditViewModel = credit
        self.reminder = ReminderViewModel(reminder: creditViewModel?.credit.reminder)
        self.selectedIconURL = credit?.iconURL
        if let expenseCategory = credit?.credit.expenseCategory {
            self.expenseCategoryViewModel = ExpenseCategoryViewModel(expenseCategory: expenseCategory)
        }
        else {
            self.expenseCategoryViewModel = nil
        }
    }
    
    override func loadTransactionsBatch(lastGotAt: Date?) -> Promise<[Transaction]> {
        return transactionsCoordinator.index(transactionableId: nil,
                                             transactionableType: nil,
                                             creditId: creditId,
                                             borrowId: nil,
                                             borrowType: nil,
                                             count: transactionsBatchSize,
                                             lastGotAt: lastGotAt)
    }
    
    override func asFilter() -> TransactionableFilter? {
        guard let id = expenseCategoryViewModel?.id, let title = expenseCategoryViewModel?.name, let type = expenseCategoryViewModel?.type else { return nil }
        return TransactionableFilter(id: id, title: title, type: type, iconURL: expenseCategoryViewModel?.iconURL, iconPlaceholder: type.defaultIconName(basketType: expenseCategoryViewModel?.basketType))
    }
    
    override func loadEntity() -> Promise<Void> {
        guard let entityId = creditId else { return Promise(error: CreditInfoError.creditIsNotSpecified)}
        return  firstly {
                    creditsCoordinator.showCredit(by: entityId)
                }.get { credit in
                    self.set(credit: CreditViewModel(credit: credit))
                }.asVoid()
    }
    
    override func entityInfoFields() -> [EntityInfoField] {
        guard let creditViewModel = creditViewModel else { return [] }
        var fields: [EntityInfoField] = [IconInfoField(fieldId: CreditInfoField.icon.rawValue,
                                                       iconType: .raster,
                                                       iconURL: selectedIconURL,
                                                       placeholder: "credit-default-icon"),
                                         BasicInfoField(fieldId: CreditInfoField.creditType.rawValue,
                                                        title: "Тип кредита",
                                                        value: creditViewModel.typeName)]
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.amount.rawValue,
                                     title: "Cумма кредита",
                                     value: creditViewModel.amount))
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.gotAt.rawValue,
                                     title: "Дата выдачи",
                                     value: creditViewModel.gotAtFormatted))
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.period.rawValue,
                                     title: "Срок",
                                     value: creditViewModel.periodFormatted))
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.returnAmount.rawValue,
                                     title: "Полная сумма выплаты",
                                     value: creditViewModel.returnAmount))
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.paidAmount.rawValue,
                                     title: "Уже оплатил",
                                     value: creditViewModel.paidAmount))
        
        fields.append(BasicInfoField(fieldId: CreditInfoField.amountLeft.rawValue,
                                     title: "Осталось оплатить",
                                     value: creditViewModel.amountLeft))
        
        if creditViewModel.areExpensesPlanned {
            fields.append(BasicInfoField(fieldId: CreditInfoField.planned.rawValue,
                                         title: "Ежемесячная выплата",
                                         value: creditViewModel.monthlyPayment))
        }
        
        fields.append(ReminderInfoField(fieldId: CreditInfoField.reminder.rawValue,
                                        reminder: reminder))
        fields.append(contentsOf: [ButtonInfoField(fieldId: CreditInfoField.statistics.rawValue,
                                                   title: "Статистика",
                                                   iconName: nil,
                                                   isEnabled: true),
                                   ButtonInfoField(fieldId: CreditInfoField.transaction.rawValue,
                                                   title: payTitle,
                                                   iconName: payIconName,
                                                   isEnabled: !creditViewModel.isPaid,
                                                   backgroundColor: payColor)])
        return fields
    }
    
    override func saveEntity() -> Promise<Void> {
        return creditsCoordinator.updateCredit(with: updateForm())
    }
         
    private func updateForm() -> CreditUpdatingForm {
        return CreditUpdatingForm(id: creditId,
                                  name: creditViewModel?.name,
                                  iconURL: selectedIconURL,
                                  amountCents: creditViewModel?.credit.amountCents,
                                  returnAmountCents: creditViewModel?.credit.returnAmountCents,
                                  monthlyPaymentCents: creditViewModel?.credit.monthlyPaymentCents,
                                  gotAt: creditViewModel?.credit.gotAt,
                                  period: creditViewModel?.credit.period,
                                  reminderAttributes: reminder.reminderAttributes,
                                  creditingTransactionAttributes: nil)
    }
}