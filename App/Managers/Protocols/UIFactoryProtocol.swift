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
                             iconCategory: IconCategory) -> UINavigationController?
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> UINavigationController?
    
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
    
    func loginViewController() -> LoginViewController?
    
    func loginNavigationController() -> UINavigationController?
    
    func forgotPasswordViewController() -> ForgotPasswordViewController?
    
    func resetPasswordViewController(email: String?) -> ResetPasswordViewController?
    
    func borrowEditViewController(delegate: BorrowEditViewControllerDelegate,
                                  type: BorrowType,
                                  borrowId: Int?,
                                  source: TransactionSource?,
                                  destination: TransactionDestination?) -> UINavigationController?
    
    func borrowInfoViewController(borrowId: Int?,
                                  borrowType: BorrowType?,
                                  borrow: BorrowViewModel?) -> UINavigationController?
    
    func creditEditViewController(delegate: CreditEditViewControllerDelegate,
                                  creditId: Int?,
                                  destination: TransactionDestination?) -> UINavigationController?
    
    func creditInfoViewController(creditId: Int?, credit: CreditViewModel?) -> UINavigationController?
        
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: TransactionSource,
                                      destination: TransactionDestination,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController?
    
    func statisticsViewController(filter: TransactionableFilter?) -> UIViewController?
    
    func statisticsModalViewController(filter: TransactionableFilter?) -> UINavigationController?
    
    func statisticsFiltersViewController(delegate: FiltersSelectionViewControllerDelegate?, dateRangeFilter: DateRangeTransactionFilter?, transactionableFilters: [TransactionableFilter]) -> UINavigationController? 
    
    func datePeriodSelectionViewController(delegate: DatePeriodSelectionViewControllerDelegate,
                                           dateRangeFilter: DateRangeTransactionFilter?,
                                           transactionsMinDate: Date?,
                                           transactionsMaxDate: Date?) -> UINavigationController?
    
    func balanceViewController() -> UINavigationController?
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate,
                                        incomeSource: IncomeSource?) -> UINavigationController?
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate,
                                        example: TransactionableExampleViewModel) -> UINavigationController?
    
    func incomeSourceInfoViewController(incomeSource: IncomeSourceViewModel?) -> UINavigationController?
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         expenseSource: ExpenseSource?) -> UINavigationController?
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         example: TransactionableExampleViewModel) -> UINavigationController?
    
    func expenseSourceInfoViewController(expenseSource: ExpenseSourceViewModel?) -> UINavigationController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           expenseCategory: ExpenseCategory?,
                                           basketType: BasketType) -> UINavigationController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           example: TransactionableExampleViewModel,
                                           basketType: BasketType) -> UINavigationController?
    
    func expenseCategoryInfoViewController(expenseCategory: ExpenseCategoryViewModel?) -> UINavigationController?
        
    func activeEditViewController(delegate: ActiveEditViewControllerDelegate,
                                  active: Active?,
                                  basketType: BasketType) -> UINavigationController?
    
    func activeInfoViewController(active: ActiveViewModel?) -> UINavigationController?
    
    func dependentIncomeSourceInfoViewController(activeName: String) -> UIViewController?
    
    func transactionCreationInfoViewController() -> UINavigationController?
}
