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
    
    func fundsMoveEditViewController(delegate: FundsMoveEditViewControllerDelegate,
                                     source: ExpenseSourceViewModel?,
                                     destination: ExpenseSourceViewModel?,
                                     borrow: BorrowViewModel?) -> UINavigationController? {
        let fundsMoveEditNavigationController = router.viewController(.FundsMoveEditNavigationController) as? UINavigationController
        let fundsMoveEditViewController = fundsMoveEditNavigationController?.topViewController as? FundsMoveEditViewController
        
        fundsMoveEditViewController?.set(delegate: delegate)
        fundsMoveEditViewController?.set(source: source, destination: destination, borrow: borrow)
        return fundsMoveEditNavigationController
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
                                  expenseSourceFrom: ExpenseSourceViewModel?,
                                  expenseSourceTo: ExpenseSourceViewModel?) -> UINavigationController? {
        let borrowEditNavigationController = router.viewController(.BorrowEditNavigationController) as? UINavigationController
        let borrowEditViewController = borrowEditNavigationController?.topViewController as? BorrowEditViewController
        
        borrowEditViewController?.set(delegate: delegate)
        if let borrowId = borrowId {
            borrowEditViewController?.set(borrowId: borrowId, type: type)
        }
        else {
            borrowEditViewController?.set(type: type, expenseSourceFrom: expenseSourceFrom, expenseSourceTo: expenseSourceTo)
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
}
