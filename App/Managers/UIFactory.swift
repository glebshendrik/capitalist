//
//  UIFactory.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import RecurrencePicker

class UIFactory : UIFactoryProtocol {
    private let router: ApplicationRouterProtocol
    
    init(router: ApplicationRouterProtocol) {
        self.router = router
    }
    
    func iconsViewController(delegate: IconsViewControllerDelegate,
                             iconCategory: IconCategory) -> UINavigationController? {
        
        guard let iconsViewController = router.viewController(.IconsViewController) as? IconsViewController else { return nil }
        iconsViewController.set(iconCategory: iconCategory)
        iconsViewController.set(delegate: delegate)
        return UINavigationController(rootViewController: iconsViewController)
    }
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> UINavigationController? {
        
        guard let currenciesViewController = router.viewController(.CurrenciesViewController) as? CurrenciesViewController else { return nil }
        currenciesViewController.set(delegate: delegate)
        return UINavigationController(rootViewController: currenciesViewController)
    }
    
    func countriesViewController(delegate: CountriesViewControllerDelegate) -> CountriesViewController? {
        let countriesViewController = router.viewController(.CountriesViewController) as? CountriesViewController
        countriesViewController?.delegate = delegate
        return countriesViewController
    }
    
    func reminderEditViewController(delegate: ReminderEditViewControllerDelegate,
                                    viewModel: ReminderViewModel) -> UINavigationController? {
        
        let reminderEditNavigationController = router.viewController(.ReminderEditNavigationController) as? UINavigationController
        let reminderEditViewController = reminderEditNavigationController?.topViewController as? ReminderEditViewController
        reminderEditViewController?.set(reminderViewModel: viewModel, delegate: delegate)
        return reminderEditNavigationController
    }
    
    func providersViewController(delegate: ProvidersViewControllerDelegate) -> ProvidersViewController? {
        
        let providersViewController = router.viewController(.ProvidersViewController) as? ProvidersViewController
        providersViewController?.delegate = delegate
        return providersViewController
    }
    
    func accountsViewController(delegate: AccountsViewControllerDelegate,
                                providerConnection: ProviderConnection,
                                currencyCode: String?) -> AccountsViewController? {
        
        let accountsViewController = router.viewController(Infrastructure.ViewController.AccountsViewController) as? AccountsViewController
        accountsViewController?.delegate = delegate
        accountsViewController?.viewModel.providerConnection = providerConnection
        accountsViewController?.viewModel.currencyCode = currencyCode
        return accountsViewController
    }
    
    func providerConnectionViewController(delegate: ProviderConnectionViewControllerDelegate,
                                          providerViewModel: ProviderViewModel) -> ProviderConnectionViewController? {
        
        let providerConnectionViewController = router.viewController(Infrastructure.ViewController.ProviderConnectionViewController) as? ProviderConnectionViewController
        providerConnectionViewController?.delegate = delegate
        providerConnectionViewController?.providerViewModel = providerViewModel
        return providerConnectionViewController        
    }
    
    func commentViewController(delegate: CommentViewControllerDelegate,
                               text: String?,
                               placeholder: String) -> CommentViewController? {
        
        let commentController = CommentViewController()
        commentController.set(delegate: delegate)        
        commentController.set(comment: text, placeholder: placeholder)
        commentController.modalPresentationStyle = .custom
        return commentController
    }
    
    func datePickerViewController(delegate: DatePickerViewControllerDelegate,
                                  date: Date?,
                                  minDate: Date?,
                                  maxDate: Date?,
                                  mode: UIDatePicker.Mode) -> DatePickerViewController? {
        
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: delegate)
        datePickerController.set(date: date, minDate: minDate, maxDate: maxDate, mode: mode)
        datePickerController.modalPresentationStyle = .custom
        return datePickerController
    }
    
    func incomeSourceSelectViewController(delegate: IncomeSourceSelectViewControllerDelegate) -> IncomeSourceSelectViewController? {
        
        let incomeSourceSelectViewController = router.viewController(.IncomeSourceSelectViewController) as? IncomeSourceSelectViewController
            
        incomeSourceSelectViewController?.set(delegate: delegate)
        return incomeSourceSelectViewController
    }
    
    func expenseSourceSelectViewController(delegate: ExpenseSourceSelectViewControllerDelegate,
                                           skipExpenseSourceId: Int?,
                                           selectionType: TransactionPart,
                                           currency: String?) -> ExpenseSourceSelectViewController? {
        
        let expenseSourceSelectViewController = router.viewController(.ExpenseSourceSelectViewController) as? ExpenseSourceSelectViewController
        
        expenseSourceSelectViewController?.set(delegate: delegate,
                                               skipExpenseSourceId: skipExpenseSourceId,
                                               selectionType: selectionType,
                                               currency: currency)
        return expenseSourceSelectViewController
    }
    
    func expenseCategorySelectViewController(delegate: ExpenseCategorySelectViewControllerDelegate) -> ExpenseCategorySelectViewController? {
        
        let expenseCategorySelectViewController = router.viewController(.ExpenseCategorySelectViewController) as? ExpenseCategorySelectViewController
        expenseCategorySelectViewController?.set(delegate: delegate)
        return expenseCategorySelectViewController
    }
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       transactionId: Int?,
                                       source: Transactionable?,
                                       destination: Transactionable?,
                                       returningBorrow: BorrowViewModel?) -> UINavigationController? {
        
        let transactionEditNavigationController = router.viewController(.TransactionEditNavigationController) as? UINavigationController
        let transactionEditViewController = transactionEditNavigationController?.topViewController as? TransactionEditViewController
        
        transactionEditViewController?.set(delegate: delegate)
        
        if let transactionId = transactionId {
            transactionEditViewController?.set(transactionId: transactionId)
        }
        else {
            transactionEditViewController?.set(source: source, destination: destination, returningBorrow: returningBorrow)
        }
        
        return transactionEditNavigationController
    }
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?,
                                       returningBorrow: BorrowViewModel?) -> UINavigationController? {
        
        return transactionEditViewController(delegate: delegate,
                                             transactionId: nil,
                                             source: source,
                                             destination: destination,
                                             returningBorrow: returningBorrow)
    }
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       source: Transactionable?,
                                       destination: Transactionable?) -> UINavigationController? {
        return transactionEditViewController(delegate: delegate,
                                             source: source,
                                             destination: destination,
                                             returningBorrow: nil)
    }
    
    func transactionEditViewController(delegate: TransactionEditViewControllerDelegate,
                                       transactionId: Int) -> UINavigationController? {
        return transactionEditViewController(delegate: delegate,
                                             transactionId: transactionId,
                                             source: nil,
                                             destination: nil,
                                             returningBorrow: nil)
    }
    
    func recurrencePicker(delegate: RecurrencePickerDelegate,
                          recurrenceRule: RecurrenceRule?,
                          ocurrenceDate: Date?) -> RecurrencePicker? {
        
        let recurrencePicker = RecurrencePicker(recurrenceRule: recurrenceRule)
        recurrencePicker.calendar = Calendar.current
        recurrencePicker.tintColor = UIColor(hexString: "6B93FB") ?? .black
        
        recurrencePicker.occurrenceDate = ocurrenceDate ?? Date()
        recurrencePicker.delegate = delegate
        return recurrencePicker
    }
    
    func loginViewController() -> LoginViewController? {
        return router.viewController(.LoginViewController) as? LoginViewController
    }
    
    func loginNavigationController() -> UINavigationController? {
        guard let loginViewController =  router.viewController(.LoginViewController) as? LoginViewController else { return nil }
        return UINavigationController(rootViewController: loginViewController)
    }
    
    func forgotPasswordViewController() -> ForgotPasswordViewController? {
        return router.viewController(.ForgotPasswordViewController) as? ForgotPasswordViewController
    }
    
    func resetPasswordViewController(email: String?) -> ResetPasswordViewController? {
        let viewController = router.viewController(.ResetPasswordViewController) as? ResetPasswordViewController
        viewController?.set(email: email)
        return viewController
    }
    
    func borrowEditViewController(delegate: BorrowEditViewControllerDelegate,
                                  type: BorrowType,
                                  borrowId: Int?,
                                  source: TransactionSource?,
                                  destination: TransactionDestination?) -> UINavigationController? {
        
        let borrowEditNavigationController = router.viewController(.BorrowEditNavigationController) as? UINavigationController
        let borrowEditViewController = borrowEditNavigationController?.topViewController as? BorrowEditViewController
        
        borrowEditViewController?.set(delegate: delegate)
        if let borrowId = borrowId {
            borrowEditViewController?.set(borrowId: borrowId, type: type)
        }
        else {            
            borrowEditViewController?.set(type: type, source: source, destination: destination)
        }
        return borrowEditNavigationController
    }
    
    func creditEditViewController(delegate: CreditEditViewControllerDelegate,
                                  creditId: Int?,
                                  destination: TransactionDestination?) -> UINavigationController? {
        
        let creditEditNavigationController = router.viewController(.CreditEditNavigationController) as? UINavigationController
        let creditEditViewController = creditEditNavigationController?.topViewController as? CreditEditViewController
        
        creditEditViewController?.set(delegate: delegate)
        if let creditId = creditId {
            creditEditViewController?.set(creditId: creditId)
        }
        else {
            creditEditViewController?.set(destination: destination)
        }
        return creditEditNavigationController
    }
    
    func datePeriodSelectionViewController(delegate: DatePeriodSelectionViewControllerDelegate,
                                           dateRangeFilter: DateRangeTransactionFilter?,
                                           transactionsMinDate: Date?,
                                           transactionsMaxDate: Date?) -> UINavigationController? {
        
        let datePeriodSelectionNavigationController = router.viewController(.DatePeriodSelectionNavigationController) as? UINavigationController
        let datePeriodSelectionViewController = datePeriodSelectionNavigationController?.topViewController as? DatePeriodSelectionViewController
        
        datePeriodSelectionViewController?.set(delegate: delegate)
        datePeriodSelectionViewController?.set(dateRangeFilter: dateRangeFilter,
                                               transactionsMinDate: transactionsMinDate,
                                               transactionsMaxDate: transactionsMaxDate)
        return datePeriodSelectionNavigationController
    }
    
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: TransactionSource,
                                      destination: TransactionDestination,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController? {
        let waitingBorrowsViewController = router.viewController(.WaitingBorrowsViewController) as? WaitingBorrowsViewController
            
        waitingBorrowsViewController?.set(delegate: delegate,
                                          source: source,
                                          destination: destination,
                                          waitingBorrows: waitingBorrows,
                                          borrowType: borrowType)
        
        return waitingBorrowsViewController
    }
    
    func statisticsViewController(filter: TransactionableFilter?)  -> UIViewController? {
        let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController
        statisticsViewController?.set(filter: filter)
        return statisticsViewController
    }
    
    func statisticsModalViewController(graphType: GraphType) -> UINavigationController? {
        guard let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController else { return nil }
        statisticsViewController.set(graphType: graphType)
        return UINavigationController(rootViewController: statisticsViewController)
    }
    
    func statisticsModalViewController(filter: TransactionableFilter?)  -> UINavigationController? {
        guard let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController else { return nil }
        statisticsViewController.set(filter: filter)
        return UINavigationController(rootViewController: statisticsViewController)
    }
    
    func statisticsFiltersViewController(delegate: FiltersSelectionViewControllerDelegate?, dateRangeFilter: DateRangeTransactionFilter?, transactionableFilters: [TransactionableFilter]) -> UINavigationController? {
        
        guard let filtersNavigationController = router.viewController(.FiltersSelectionNavigationViewController) as? UINavigationController,
            let filtersViewController = filtersNavigationController.topViewController as? FiltersSelectionViewController else { return nil }
                
        filtersViewController.delegate = delegate
        filtersViewController.set(filters: transactionableFilters)
        return filtersNavigationController
    }
    
    func balanceViewController() -> UINavigationController? {        
        return UINavigationController(rootViewController: router.viewController(.BalanceViewController))
    }
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate,
                                        incomeSource: IncomeSource?) -> UINavigationController? {
        let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController
        let incomeSourceEditViewController = incomeSourceEditNavigationController?.topViewController as? IncomeSourceEditViewController
            
        incomeSourceEditViewController?.set(delegate: delegate)
            
        if let incomeSource = incomeSource {
            incomeSourceEditViewController?.set(incomeSource: incomeSource)
        }
                        
        return incomeSourceEditNavigationController
    }
    
    func incomeSourceEditViewController(delegate: IncomeSourceEditViewControllerDelegate, example: TransactionableExampleViewModel) -> UINavigationController? {
        let incomeSourceEditNavigationController = router.viewController(.IncomeSourceEditNavigationController) as? UINavigationController
        let incomeSourceEditViewController = incomeSourceEditNavigationController?.topViewController as? IncomeSourceEditViewController
            
        incomeSourceEditViewController?.set(delegate: delegate)
            
        incomeSourceEditViewController?.viewModel.set(example: example)
                        
        return incomeSourceEditNavigationController
    }
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate,
                                         expenseSource: ExpenseSource?) -> UINavigationController? {
        let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController
        let expenseSourceEditViewController = expenseSourceEditNavigationController?.topViewController as? ExpenseSourceEditViewController
            
        expenseSourceEditViewController?.set(delegate: delegate)
            
        if let expenseSource = expenseSource {
            expenseSourceEditViewController?.set(expenseSource: expenseSource)
        }
        
        return expenseSourceEditNavigationController
    }
    
    func expenseSourceEditViewController(delegate: ExpenseSourceEditViewControllerDelegate, example: TransactionableExampleViewModel) -> UINavigationController? {
        let expenseSourceEditNavigationController = router.viewController(.ExpenseSourceEditNavigationController) as? UINavigationController
        let expenseSourceEditViewController = expenseSourceEditNavigationController?.topViewController as? ExpenseSourceEditViewController
            
        expenseSourceEditViewController?.set(delegate: delegate)
        expenseSourceEditViewController?.viewModel.set(example: example)
        
        return expenseSourceEditNavigationController
    }
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate,
                                           expenseCategory: ExpenseCategory?,
                                           basketType: BasketType) -> UINavigationController? {
        let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController
        let expenseCategoryEditViewController = expenseCategoryEditNavigationController?.topViewController as? ExpenseCategoryEditViewController
            
        expenseCategoryEditViewController?.set(delegate: delegate)
        expenseCategoryEditViewController?.set(basketType: basketType)
        
        if let expenseCategory = expenseCategory {
            expenseCategoryEditViewController?.set(expenseCategory: expenseCategory)
        }        
        return expenseCategoryEditNavigationController
    }
    
    func expenseCategoryEditViewController(delegate: ExpenseCategoryEditViewControllerDelegate, example: TransactionableExampleViewModel, basketType: BasketType) -> UINavigationController? {
        let expenseCategoryEditNavigationController = router.viewController(.ExpenseCategoryEditNavigationController) as? UINavigationController
        let expenseCategoryEditViewController = expenseCategoryEditNavigationController?.topViewController as? ExpenseCategoryEditViewController
            
        expenseCategoryEditViewController?.set(delegate: delegate)
        expenseCategoryEditViewController?.set(basketType: basketType)
        expenseCategoryEditViewController?.viewModel.set(example: example)

        return expenseCategoryEditNavigationController
    }
    
    func activeEditViewController(delegate: ActiveEditViewControllerDelegate,
                                  active: Active?,
                                  basketType: BasketType) -> UINavigationController? {
        let activeEditNavigationController = router.viewController(.ActiveEditNavigationController) as? UINavigationController
        let activeEditViewController = activeEditNavigationController?.topViewController as? ActiveEditViewController
            
        activeEditViewController?.set(delegate: delegate)
        activeEditViewController?.set(basketType: basketType)
        
        if let active = active {
            activeEditViewController?.set(active: active)
        }
        return activeEditNavigationController
    }
    
    func activeSelectViewController(delegate: ActiveSelectViewControllerDelegate,
                                    skipActiveId: Int?,
                                    selectionType: TransactionPart) -> ActiveSelectViewController? {
        let activeSelectViewController = router.viewController(.ActiveSelectViewController) as? ActiveSelectViewController
        
        activeSelectViewController?.set(delegate: delegate,
                                               skipActiveId: skipActiveId,
                                               selectionType: selectionType)
        return activeSelectViewController
    }
    
    func dependentIncomeSourceInfoViewController(activeName: String) -> UIViewController? {
        
        let dependentIncomeSourceInfoViewController = router.viewController(.DependentIncomeSourceInfoViewController) as? DependentIncomeSourceInfoViewController
                
        dependentIncomeSourceInfoViewController?.activeName = activeName
//        dependentIncomeSourceInfoViewController?.modalPresentationStyle = .overCurrentContext
//        dependentIncomeSourceInfoViewController?.modalTransitionStyle = .crossDissolve
        return dependentIncomeSourceInfoViewController    
    }
    
    func transactionCreationInfoViewController() -> UINavigationController? {
        guard let transactionCreationInfoViewController = router.viewController(.TransactionCreationInfoViewController) as? TransactionCreationInfoViewController else { return nil }
        return UINavigationController(rootViewController: transactionCreationInfoViewController)
    }
    
    func incomeSourceInfoViewController(incomeSource: IncomeSourceViewModel?) -> UINavigationController? {
        let incomeSourceInfoViewController = router.viewController(.IncomeSourceInfoViewController) as? IncomeSourceInfoViewController
        
        incomeSourceInfoViewController?.viewModel.set(incomeSource: incomeSource)
        
        return incomeSourceInfoViewController
    }
    
    func expenseSourceInfoViewController(expenseSource: ExpenseSourceViewModel?) -> UINavigationController? {
        let expenseSourceInfoViewController = router.viewController(.ExpenseSourceInfoViewController) as? ExpenseSourceInfoViewController
        
        expenseSourceInfoViewController?.viewModel.set(expenseSource: expenseSource)
        
        return expenseSourceInfoViewController
    }
    
    func expenseCategoryInfoViewController(expenseCategory: ExpenseCategoryViewModel?) -> UINavigationController? {
        let expenseCategoryInfoViewController = router.viewController(.ExpenseCategoryInfoViewController) as? ExpenseCategoryInfoViewController
        
        expenseCategoryInfoViewController?.viewModel.set(expenseCategory: expenseCategory)
        
        return expenseCategoryInfoViewController
    }
    
    func activeInfoViewController(active: ActiveViewModel?) -> UINavigationController? {
        let activeInfoViewController = router.viewController(.ActiveInfoViewController) as? ActiveInfoViewController
        
        activeInfoViewController?.viewModel.set(active: active)
        
        return activeInfoViewController
    }
    
    func creditInfoViewController(creditId: Int?, credit: CreditViewModel?) -> UINavigationController? {
        let creditInfoViewController = router.viewController(.CreditInfoViewController) as? CreditInfoViewController
        
        if let credit = credit {
            creditInfoViewController?.viewModel.set(credit: credit)
        }
        else {
            creditInfoViewController?.viewModel.creditId = creditId
        }
        
        return creditInfoViewController
    }
    
    func borrowInfoViewController(borrowId: Int?,
                                  borrowType: BorrowType?,
                                  borrow: BorrowViewModel?) -> UINavigationController? {
        
        let borrowInfoViewController = router.viewController(.BorrowInfoViewController) as? BorrowInfoViewController
        
        if let borrow = borrow {
            borrowInfoViewController?.viewModel.set(borrow: borrow)
        }
        else {
            borrowInfoViewController?.viewModel.borrowId = borrowId
            borrowInfoViewController?.viewModel.borrowType = borrowType
        }
        
        
        return borrowInfoViewController
    }
    
    func subscriptionViewController() -> UINavigationController? {
        guard let subscriptionViewController = router.viewController(.SubscriptionViewController) as? SubscriptionViewController else { return nil }
        return UINavigationController(rootViewController: subscriptionViewController)
    }
}
