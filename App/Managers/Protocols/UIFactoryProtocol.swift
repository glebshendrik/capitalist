//
//  UIFactoryProtocol.swift
//  Capitalist
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
    func appUpdateViewController() -> UINavigationController?
    func iconsViewController(delegate: IconsViewControllerDelegate,
                             iconCategory: IconCategory) -> UINavigationController?
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> UINavigationController?
    
    func countriesViewController(delegate: CountriesViewControllerDelegate) -> CountriesViewController?
    
    func reminderEditViewController(delegate: ReminderEditViewControllerDelegate,
                                    viewModel: ReminderViewModel) -> UINavigationController?
    
    func providersViewController(delegate: ProvidersViewControllerDelegate,
                                 codes: [String]) -> UINavigationController?
    
    func connectionViewController(delegate: ConnectionViewControllerDelegate,
                                  providerViewModel: ProviderViewModel?,
                                  connection: Connection?,
                                  connectionSession: ConnectionSession) -> UINavigationController?
    
    func accountsViewController(delegate: AccountsViewControllerDelegate,
                                expenseSource: ExpenseSource) -> AccountsViewController?
    
    func datePickerViewController(delegate: DatePickerViewControllerDelegate,
                                  date: Date?,
                                  minDate: Date?,
                                  maxDate: Date?,
                                  mode: UIDatePicker.Mode) -> DatePickerViewController?
    
    func incomeSourceSelectViewController(delegate: IncomeSourceSelectViewControllerDelegate) -> IncomeSourceSelectViewController?
    
    func expenseSourceSelectViewController(delegate: ExpenseSourcesViewControllerDelegate,
                                           skipExpenseSourceId: Int?,
                                           selectionType: TransactionPart,
                                           currency: String?) -> ExpenseSourceSelectViewController?
    
    func expenseCategorySelectViewController(delegate: ExpenseCategorySelectViewControllerDelegate) -> ExpenseCategorySelectViewController?
    
    func activeSelectViewController(delegate: ActivesViewControllerDelegate,
                                    skipActiveId: Int?,
                                    selectionType: TransactionPart) -> ActiveSelectViewController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?,
                                       returningBorrow: BorrowViewModel?,
                                       transactionType: TransactionType?) -> UINavigationController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?,
                                       transactionType: TransactionType?) -> UINavigationController?
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       transactionId: Int,
                                       transactionType: TransactionType?) -> UINavigationController?
    
    func recurrencePicker(delegate: RecurrencePickerDelegate,
                          recurrenceRule: RecurrenceRule?,
                          ocurrenceDate: Date?) -> RecurrencePicker?
    
    func loginViewController() -> LoginViewController?
    
    func loginNavigationController() -> UINavigationController?
    
    func forgotPasswordViewController() -> ForgotPasswordViewController?
    
    func resetPasswordViewController(email: String?) -> ResetPasswordViewController?
    
    func borrowEditViewController(delegate: BorrowEditViewControllerDelegate,
                                  type: BorrowType,
                                  borrowId: Int?,
                                  source: TransactionSource?,
                                  destination: TransactionDestination?,
                                  borrowingTransaction: Transaction?) -> UINavigationController?
    
    func borrowInfoViewController(borrowId: Int?,
                                  borrowType: BorrowType?,
                                  borrow: BorrowViewModel?) -> UINavigationController?
    
    func creditEditViewController(delegate: CreditEditViewControllerDelegate,
                                  creditId: Int?,
                                  source: IncomeSourceViewModel?,
                                  destination: TransactionDestination?,
                                  creditingTransaction: Transaction?) -> UINavigationController?
    
    func creditInfoViewController(creditId: Int?, credit: CreditViewModel?) -> UINavigationController?
        
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: TransactionSource,
                                      destination: TransactionDestination,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController?
    
    func statisticsViewController(filter: TransactionableFilter?) -> UIViewController?
    
    func statisticsModalViewController(filter: TransactionableFilter?) -> UINavigationController?
    
    func statisticsModalViewController(graphType: GraphType) -> UINavigationController?
    
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
                                         expenseSource: ExpenseSource?,
                                         shouldSkipExamplesPrompt: Bool) -> UINavigationController?
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         example: TransactionableExampleViewModel) -> UINavigationController?
    
    func expenseSourceInfoViewController(expenseSource: ExpenseSourceViewModel?) -> UINavigationController?
    
    func cardTypesViewController(delegate: CardTypesViewControllerDelegate) -> UINavigationController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           expenseCategory: ExpenseCategory?,
                                           basketType: BasketType) -> UINavigationController?
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           example: TransactionableExampleViewModel,
                                           basketType: BasketType) -> UINavigationController?
    
    func expenseCategoryInfoViewController(expenseCategory: ExpenseCategoryViewModel?) -> UINavigationController?
        
    func activeEditViewController(delegate: ActiveEditViewControllerDelegate,
                                  active: Active?,
                                  basketType: BasketType,
                                  costCents: Int?) -> UINavigationController?
    
    func activeInfoViewController(active: ActiveViewModel?) -> UINavigationController?
    
    func dependentIncomeSourceInfoViewController(activeName: String) -> UIViewController?
    
    func transactionCreationInfoViewController() -> UINavigationController?
    
    func subscriptionNavigationViewController(requiredPlans: [SubscriptionPlan]) -> UINavigationController?
    
    func subscriptionViewController(requiredPlans: [SubscriptionPlan]) -> SubscriptionViewController?
    
    func experimentalBankFeatureViewController(delegate: ExperimentalBankFeatureViewControllerDelegate) -> UINavigationController?
    
    func transactionableExamplesViewController(delegate: TransactionableExamplesViewControllerDelegate,
                                               transactionableType: TransactionableType,
                                               isUsed: Bool) -> TransactionableExamplesViewController?
    
    func prototypesLinkingViewController(linkingType: TransactionableType) -> UINavigationController?
}
