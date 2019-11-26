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
                                           currency: String?) -> ExpenseSourceSelectViewController?
    
    func expenseCategorySelectViewController(delegate: ExpenseCategorySelectViewControllerDelegate) -> ExpenseCategorySelectViewController?
    
    func activeSelectViewController(delegate: ActiveSelectViewControllerDelegate,
                                    skipActiveId: Int?,
                                    selectionType: TransactionPart) -> ActiveSelectViewController?
    
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
                                  source: TransactionSource?,
                                  destination: TransactionDestination?) -> UINavigationController?
    
    func creditEditViewController(delegate: CreditEditViewControllerDelegate,
                                  creditId: Int?,
                                  destination: TransactionDestination?) -> UINavigationController?
    
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: TransactionSource,
                                      destination: TransactionDestination,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController?
    
    func statisticsViewController(filter: SourceOrDestinationTransactionFilter?) -> UIViewController?
    
    func balanceViewController() -> UIViewController?
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate,
                                        incomeSource: IncomeSource?) -> UINavigationController?
    
    func incomeSourceInfoViewController(incomeSource: IncomeSourceViewModel?) -> UIViewController?
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         expenseSource: ExpenseSource?) -> UINavigationController?
    
    func expenseSourceInfoViewController(expenseSource: ExpenseSourceViewModel?) -> UIViewController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           expenseCategory: ExpenseCategory?,
                                           basketType: BasketType) -> UINavigationController?
        
    func activeEditViewController(delegate: ActiveEditViewControllerDelegate,
                                  active: Active?,
                                  basketType: BasketType) -> UINavigationController?
    
    
    func dependentIncomeSourceInfoViewController(activeName: String) -> UIViewController?
}
