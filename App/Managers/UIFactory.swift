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
                             iconCategory: IconCategory) -> IconsViewController? {
        
        let iconsViewController = router.viewController(.IconsViewController) as? IconsViewController
        iconsViewController?.set(iconCategory: iconCategory)
        iconsViewController?.set(delegate: delegate)
        return iconsViewController
    }
    
    func currenciesViewController(delegate: CurrenciesViewControllerDelegate) -> CurrenciesViewController? {
        
        let currenciesViewController = router.viewController(.CurrenciesViewController) as? CurrenciesViewController
        currenciesViewController?.set(delegate: delegate)
        return currenciesViewController
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
                                           noDebts: Bool,
                                           accountType: AccountType?,
                                           currency: String?) -> ExpenseSourceSelectViewController? {
        
        let expenseSourceSelectViewController = router.viewController(.ExpenseSourceSelectViewController) as? ExpenseSourceSelectViewController
        
        expenseSourceSelectViewController?.set(delegate: delegate,
                                               skipExpenseSourceId: skipExpenseSourceId,
                                               selectionType: selectionType,
                                               noDebts: noDebts,
                                               accountType: accountType,
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
                          ocurrenceDate: Date?,
                          language: RecurrencePickerLanguage) -> RecurrencePicker? {
        
        let recurrencePicker = RecurrencePicker(recurrenceRule: recurrenceRule)
        recurrencePicker.language = language
        recurrencePicker.calendar = Calendar.current
        recurrencePicker.tintColor = UIColor(hexString: "6B93FB") ?? .black
        
        recurrencePicker.occurrenceDate = ocurrenceDate ?? Date()
        recurrencePicker.delegate = delegate
        return recurrencePicker
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
                                  source: ExpenseSourceViewModel?,
                                  destination: ExpenseSourceViewModel?) -> UINavigationController? {
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
                                  creditId: Int?) -> UINavigationController? {
        let creditEditNavigationController = router.viewController(.CreditEditNavigationController) as? UINavigationController
        let creditEditViewController = creditEditNavigationController?.topViewController as? CreditEditViewController
        
        creditEditViewController?.set(delegate: delegate)
        if let creditId = creditId {
            creditEditViewController?.set(creditId: creditId)
        }
        return creditEditNavigationController
    }
    
    func waitingBorrowsViewController(delegate: WaitingBorrowsViewControllerDelegate,
                                      source: ExpenseSourceViewModel,
                                      destination: ExpenseSourceViewModel,
                                      waitingBorrows: [BorrowViewModel],
                                      borrowType: BorrowType) -> UIViewController? {
        let waitingBorrowsViewController = router.viewController(.WaitingBorrowsViewController) as? WaitingBorrowsViewController
            
        waitingBorrowsViewController?.set(delegate: delegate, source: source, destination: destination, waitingBorrows: waitingBorrows, borrowType: borrowType)
        
        return waitingBorrowsViewController
    }
    
    func statisticsViewController(filter: SourceOrDestinationTransactionFilter)  -> UIViewController? {
        let statisticsViewController = router.viewController(.StatisticsViewController) as? StatisticsViewController
        statisticsViewController?.set(sourceOrDestinationFilter: filter)
        return statisticsViewController
    }
    
    func balanceViewController() -> UIViewController? {
        return router.viewController(.BalanceViewController)
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
}
