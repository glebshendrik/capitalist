//
//  UIFactoryProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import RecurrencePicker

protocol UIFactoryDependantProtocol {
    var factory: UIFactoryProtocol! { get set }
}

protocol UIFactoryProtocol {
    func iconsViewController(delegate: IconsViewControllerDelegate,
                             iconCategory: IconCategory) -> IconsViewController?
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> CurrenciesViewController?
    
    func reminderEditViewController(delegate: ReminderEditViewControllerDelegate,
                                    viewModel: ReminderViewModel) -> UINavigationController?
    
    func providersViewController(delegate: ProvidersViewControllerDelegate) -> ProvidersViewController?
    
    func accountsViewController(delegate: AccountsViewControllerDelegate,
                                providerConnection: ProviderConnection,
                                currencyCode: String?) -> AccountsViewController?
    
    func providerConnectionViewController(delegate: ProviderConnectionViewControllerDelegate,
                                          providerViewModel: ProviderViewModel) -> ProviderConnectionViewController?
    
    func commentViewController(delegate: CommentViewControllerDelegate,
                               text: String?,
                               placeholder: String) -> CommentViewController?
    
    func datePickerViewController(delegate: DatePickerViewControllerDelegate,
                                  date: Date?,
                                  minDate: Date?,
                                  maxDate: Date?,
                                  mode: UIDatePicker.Mode) -> DatePickerViewController?
    
    func incomeSourceSelectViewController(delegate: IncomeSourceSelectViewControllerDelegate) -> IncomeSourceSelectViewController?
    
    func expenseSourceSelectViewController(delegate: ExpenseSourceSelectViewControllerDelegate,
                                           skipExpenseSourceId: Int?,
                                           selectionType: TransactionPart,
                                           noDebts: Bool,
                                           accountType: AccountType?,
                                           currency: String?) -> ExpenseSourceSelectViewController?
    
    func expenseCategorySelectViewController(delegate: ExpenseCategorySelectViewControllerDelegate) -> ExpenseCategorySelectViewController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?,
                                       returningBorrow: BorrowViewModel?) -> UINavigationController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?) -> UINavigationController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       transactionId: Int) -> UINavigationController?
    
    func recurrencePicker(delegate: RecurrencePickerDelegate,
                          recurrenceRule: RecurrenceRule?,
                          ocurrenceDate: Date?,
                          language: RecurrencePickerLanguage) -> RecurrencePicker?
    
    func forgotPasswordViewController() -> ForgotPasswordViewController?
    
    func resetPasswordViewController(email: String?) -> ResetPasswordViewController?
    
    func borrowEditViewController(delegate: BorrowEditViewControllerDelegate,
                                  type: BorrowType,
                                  borrowId: Int?,
                                  source: ExpenseSourceViewModel?,
                                  destination: ExpenseSourceViewModel?) -> UINavigationController?
    
    func creditEditViewController(delegate: CreditEditViewControllerDelegate,
                                  creditId: Int?) -> UINavigationController?
    
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: ExpenseSourceViewModel,
                                      destination: ExpenseSourceViewModel,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController?
    
    func statisticsViewController(filter: SourceOrDestinationTransactionFilter) -> UIViewController?
    
    func balanceViewController() -> UIViewController?
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate,
                                        incomeSource: IncomeSource?) -> UINavigationController?
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         expenseSource: ExpenseSource?) -> UINavigationController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           expenseCategory: ExpenseCategory?,
                                           basketType: BasketType) -> UINavigationController?
}
